import * as path from 'path';
import { push } from './push';
import * as asyncUtils from './utils/async';
import { loadConfig, getStagingFolder, getConfig } from './utils/config';
import { getSortedDefinitionBuildList, getDefinition } from './domain/definition-factory';
import { CommonParams } from './domain/common';
import { Definition, CgComponent } from './domain/definition';
import { getAllContentInfo, ExtractedInfo } from './utils/image-info-extractor';
import { ComponentInfoTransformer } from './transformers/component-transformer';
import { MarkdownInfoTransformer } from './transformers/markdown-transformer';
import * as handlebars from 'handlebars';

let releaseNotesHeaderTemplate, releaseNotesVariantPartTemplate;

interface FileContents {
    registrations?: CgComponent[];
    markdown?: string;
    version?: string;
}

// Register helper for anchors - Adapted from https://github.com/gjtorikian/html-pipeline/blob/main/lib/html/pipeline/toc_filter.rb
handlebars.registerHelper('anchor', (value) => value.toLowerCase().replace(/[^\w\- ]/g, '').replace(/ /g, '-'));

export async function generateImageInformationFiles(params: CommonParams, buildFirst: boolean, pruneBetweenDefinitions: boolean, generateCgManifest: boolean, generateMarkdown: boolean, overwrite: boolean, outputPath: string, definitionId: string) {

        // Stage content and load config
    const stagingFolder = await getStagingFolder(params.release);
    await loadConfig(stagingFolder);

    const alreadyRegistered = {};
    const cgManifest = {
        "Registrations": [],
        "Version": 1
    }

    // cgmanifest file path and whether it exists
    const cgManifestPath = path.join(outputPath, 'cgmanifest.json');
    const cgManifestExists = await asyncUtils.exists(cgManifestPath);

    console.log('(*) Generating image information files...');
    const definitions = definitionId ? [getDefinition(definitionId)] : getSortedDefinitionBuildList();
    await asyncUtils.forEach(definitions, async (currentDefinition: Definition) => {
        // Target file paths and whether they exist
        const historyFolderPath = path.join(outputPath, currentDefinition.relativePath, getConfig('historyFolderName', 'history'));
        const markdownPath = path.join(historyFolderPath, `${currentDefinition.getVersionForRelease(params.release)}.md`);
        const markdownExists = await asyncUtils.exists(markdownPath);

        // Skip if not overwriting and all files exist
        if(! overwrite && 
            (! generateMarkdown || markdownExists) && 
            (! generateCgManifest || cgManifestExists)) {
            console.log(`(*) Skipping ${currentDefinition.id}. Not in overwrite mode and content already exists.`);
            return;
        }

        // Extract information
        const fileContents = await getDefinitionImageContentData(params, currentDefinition, alreadyRegistered, buildFirst);

        // Write markdown file as appropriate
        if (generateMarkdown && (overwrite || ! markdownExists)) {
            console.log('(*) Writing image history markdown...');
            await asyncUtils.mkdirp(historyFolderPath);
            await asyncUtils.writeFile(markdownPath, fileContents.markdown);    
        }

        // Add component registrations if we're using them
        if (generateCgManifest) {
            cgManifest.Registrations = cgManifest.Registrations.concat(fileContents.registrations);     
        }
        // Prune images if setting enabled
        if (pruneBetweenDefinitions) {
            await asyncUtils.spawn('docker', ['image', 'prune', '-a', '-f']);
        }
    });

    // Write final cgmanifest.json file if needed
    if(generateCgManifest && (overwrite || ! cgManifestExists)) {
        console.log('(*) Writing cgmanifest.json...');
        await asyncUtils.writeFile(
            path.join(outputPath, 'cgmanifest.json'),
            JSON.stringify(cgManifest, undefined, 4));    
    }
    console.log('(*) Done!');
}

async function getDefinitionImageContentData(params: CommonParams, definition: Definition, alreadyRegistered: {}, buildFirst: boolean): Promise<FileContents> {
    if (typeof definition.dependencies !== 'object') {
        return {};
    }

    let registrations = [];

    const version = definition.getVersionForRelease(params.release);

    // Create header for markdown
    let markdown = await generateReleaseNotesHeader(params, definition);

    await asyncUtils.forEach(definition.variants, async (variant: string) => {
        if(variant) {
            console.log(`\n(*) Processing variant ${variant}...`);
        }

        const imageTag = definition.getTagsForRelease(params.release, params.registry, params.repository, variant)[0];
        if (buildFirst) {
            // Build but don't push images
            console.log('(*) Building image...');
            await push(params, false, false, false, [], 1, 1, false, definition.id);
        } else {
            console.log(`(*) Pulling image ${imageTag}...`);
            await asyncUtils.spawn('docker', ['pull', imageTag]);
        }

        // Extract content information
        const contents = await getAllContentInfo(imageTag, definition.dependencies);
        
        // Update markdown content
        markdown = markdown + await generateReleaseNotesPart(contents, params, definition, variant);

        // Add to registrations
        registrations = registrations.concat(getUniqueComponents(alreadyRegistered, contents));
    });

    // Register upstream images
    await asyncUtils.forEach(definition.dependencies.imageVariants, (async (imageTag: string) => {
        if (typeof alreadyRegistered[imageTag] === 'undefined') {
            const [image, imageVersion] = imageTag.split(':');
            registrations.push({
                "Component": {
                    "Type": "other",
                    "Other": {
                        "Name": `Docker Image: ${image}`,
                        "Version": imageVersion,
                        "DownloadUrl": definition.dependencies.imageLink
                    }
                }
            });
            alreadyRegistered[definition.dependencies.image] = [imageVersion];
        }
    }));

    return {
        registrations: registrations,
        markdown: markdown,
        version: version
    }
}

// Filter out components already in the registration list and format output returns an array of formatted and filtered contents
function getUniqueComponents(alreadyRegistered: {}, info: ExtractedInfo): CgComponent[] {
    let uniqueComponentList = [];

    const transformer = new ComponentInfoTransformer(info.distro);
    const cgManifestInfo = transformer.transform(info);
    for (let contentType in cgManifestInfo) {
        let cgComponents: CgComponent[] = cgManifestInfo[contentType];
        uniqueComponentList = uniqueComponentList.concat(cgComponents.reduce((prev: CgComponent[], next: CgComponent) => {
            const uniqueId = JSON.stringify(next);
            if(!alreadyRegistered[uniqueId]) {
                alreadyRegistered[uniqueId] = true;
                prev.push(next);
            }
            return prev;
        }, []));
    }
    
    return uniqueComponentList;
}

// Use template to generate header of version markdown content
async function generateReleaseNotesHeader(params: CommonParams, definition: Definition): Promise<string> {
    releaseNotesHeaderTemplate = releaseNotesHeaderTemplate || handlebars.compile(await asyncUtils.readFile(path.join(__dirname, '..', 'assets', 'release-notes-header.md')));
    const data = {
        version: definition.getVersionForRelease(params.release),
        definition: definition.id,
        release: params.release,
        annotation: definition.dependencies.annotation,
        repository: params.githubRepo,
        variants: definition.variants,
        hasVariants: definition.variants && definition.variants[0]
    }
    return releaseNotesHeaderTemplate(data);
}

// Generate release notes section for variant
async function generateReleaseNotesPart(info: ExtractedInfo, params: CommonParams, definition: Definition, variant: string): Promise<string> {
    releaseNotesVariantPartTemplate = releaseNotesVariantPartTemplate || handlebars.compile(await asyncUtils.readFile(path.join(__dirname, '..', 'assets', 'release-notes-variant-part.md')));
    const transformer = new MarkdownInfoTransformer();
    const markdownInfo = transformer.transform(info);
    markdownInfo.hasPip = markdownInfo.pip.length > 0 || markdownInfo.pipx.length > 0;
    markdownInfo.tags = definition.getTagList(params.release, 'full-only', params.stubRegistry, params.stubRepository, variant);    
    markdownInfo.variant = variant;
    return releaseNotesVariantPartTemplate(markdownInfo);
}
