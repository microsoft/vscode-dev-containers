const path = require('path');
const push = require('./push').push;
const asyncUtils = require('./utils/async');
const configUtils = require('./utils/config');
const imageContentUtils = require('./utils/image-content-extractor');
const componentFormatterFactory = require('./utils/component-formatter-factory');
const markdownFormatterFactory = require('./utils/markdown-formatter-factory');
const handlebars = require('handlebars');
let releaseNotesHeaderTemplate, releaseNotesVariantPartTemplate;

// Register helper for anchors - Adapted from https://github.com/gjtorikian/html-pipeline/blob/main/lib/html/pipeline/toc_filter.rb
handlebars.registerHelper('anchor', (value) => value.toLowerCase().replace(/[^\w\- ]/g, '').replace(/ /g, '-'));

async function generateImageInformationFiles(repo, release, registry, registryPath, 
    stubRegistry, stubRegistryPath, buildFirst, pruneBetweenDefinitions, generateCgManifest, generateMarkdown, overwrite, outputPath, definitionId) {
    // Load config files
    await configUtils.loadConfig();

    const alreadyRegistered = {};
    const cgManifest = {
        "Registrations": [],
        "Version": 1
    }

    // cgmanifest file path and whether it exists
    const cgManifestPath = path.join(outputPath, 'cgmanifest.json');
    const cgManifestExists = await asyncUtils.exists(cgManifestPath);

    console.log('(*) Generating image information files...');
    const definitions = definitionId ? [definitionId] : configUtils.getSortedDefinitionBuildList();
    await asyncUtils.forEach(definitions, async (currentDefinitionId) => {
        // Target file paths and whether they exist
        const definitionRelativePath = configUtils.getDefinitionPath(currentDefinitionId, true);
        const historyFolder = path.join(outputPath, definitionRelativePath, configUtils.getConfig('historyFolderName', 'history'));
        const version = configUtils.getVersionFromRelease(release, currentDefinitionId);
        const markdownPath = path.join(historyFolder, `${version}.md`);
        const markdownExists = await asyncUtils.exists(markdownPath);

        // Skip if not overwriting and all files exist
        if(! overwrite && 
            (! generateMarkdown || markdownExists) && 
            (! generateCgManifest || cgManifestExists)) {
            console.log(`(*) Skipping ${currentDefinitionId}. Not in overwrite mode and content already exists.`);
            return;
        }

        // Extract information
        const definitionInfo = await getDefinitionImageContent(repo, release, registry, registryPath,  stubRegistry, stubRegistryPath, currentDefinitionId, alreadyRegistered, buildFirst);

        // Write markdown file as appropriate
        if (generateMarkdown && (overwrite || ! markdownExists)) {
            console.log('(*) Writing image history markdown...');
            await asyncUtils.mkdirp(historyFolder);
            await asyncUtils.writeFile(markdownPath, definitionInfo.markdown);    
        }

        // Add component registrations if we're using them
        if (generateCgManifest) {
            cgManifest.Registrations = cgManifest.Registrations.concat(definitionInfo.registrations);     
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

async function getDefinitionImageContent(repo, release, registry, registryPath, stubRegistry, stubRegistryPath, definitionId, alreadyRegistered, buildFirst) {
    const dependencies = configUtils.getDefinitionDependencies(definitionId);
    if (typeof dependencies !== 'object') {
        return [];
    }

    let registrations = [];


    const variants = configUtils.getVariants(definitionId) || [null];
    const version = configUtils.getVersionFromRelease(release, definitionId);

    // Create header for markdown
    let markdown = await generateReleaseNotesHeader(repo, release, definitionId, variants, dependencies);

    await asyncUtils.forEach(variants, async (variant) => {
        if(variant) {
            console.log(`\n(*) Processing variant ${variant}...`);
        }

        const imageTag = configUtils.getTagsForVersion(definitionId, version, registry, registryPath, variant)[0];
        if (buildFirst) {
            // Build but don't push images
            console.log('(*) Building image...');
            await push(repo, release, false, registry, registryPath, registry, registryPath, false, false, [], 1, 1, false, definitionId);
        } else {
            console.log(`(*) Pulling image ${imageTag}...`);
            await asyncUtils.spawn('docker', ['pull', imageTag]);
        }

        // Extract content information
        const contents = await imageContentUtils.getAllContentInfo(imageTag, dependencies);
        
        // Update markdown content
        markdown = markdown + await generateReleaseNotesPart(contents, release, stubRegistry, stubRegistryPath, definitionId, variant);

        // Add to registrations
        registrations = registrations.concat(getUniqueComponents(alreadyRegistered, contents));
    });

    // Register upstream images
    await asyncUtils.forEach(dependencies.imageVariants, (async (imageTag) => {
        if (typeof alreadyRegistered[imageTag] === 'undefined') {
            const [image, imageVersion] = imageTag.split(':');
            registrations.push({
                "Component": {
                    "Type": "other",
                    "Other": {
                        "Name": `Docker Image: ${image}`,
                        "Version": imageVersion,
                        "DownloadUrl": dependencies.imageLink
                    }
                }
            });
            alreadyRegistered[dependencies.image] = [imageVersion];
        }
    }));

    return {
        registrations: registrations,
        markdown: markdown,
        version: version
    }
}

// Filter out components already in the registration list and format output returns an array of formatted and filtered contents
function getUniqueComponents(alreadyRegistered, contents) {
    let componentList = [];

    const contentFormatter = componentFormatterFactory.getFormatter(contents.distro);
    for (let contentType in contents) {
        const formatterFn = contentFormatter[contentType];
        let content = contents[contentType];
        if (formatterFn && content) {
            if(!Array.isArray(content)) {
                content = [content];
            }
            componentList = componentList.concat(content.reduce((prev, next) => {
                const uniqueId = JSON.stringify(next);
                if(!alreadyRegistered[uniqueId]) {
                    alreadyRegistered[uniqueId] = true;
                    const component = formatterFn(next);
                    if(component) {
                        prev.push(component);
                    }
                }
                return prev;
            }, []));
        }
    }
    
    return componentList;
}

// Use template to generate header of version markdown content
async function generateReleaseNotesHeader(repo, release, definitionId, variants, dependencies) {
    releaseNotesHeaderTemplate = releaseNotesHeaderTemplate || handlebars.compile(await asyncUtils.readFile(path.join(__dirname, '..', 'assets', 'release-notes-header.md')));
    const data = {
        version: configUtils.getVersionFromRelease(release, definitionId),
        definition: definitionId,
        release: release,
        annotation: dependencies.annotation,
        repository: repo,
        variants: variants,
        hasVariants: variants && variants[0]
    }
    return releaseNotesHeaderTemplate(data);
}

// Generate release notes section for variant
async function generateReleaseNotesPart(contents, release, stubRegistry, stubRegistryPath, definitionId, variant) {
    releaseNotesVariantPartTemplate = releaseNotesVariantPartTemplate || handlebars.compile(await asyncUtils.readFile(path.join(__dirname, '..', 'assets', 'release-notes-variant-part.md')));
    const markdownFormatter = markdownFormatterFactory.getFormatter();
    const formattedContents = getFormattedContents(contents, markdownFormatter);
    formattedContents.hasPip = formattedContents.pip.length > 0 || formattedContents.pipx.length > 0;
    formattedContents.tags = configUtils.getTagList(definitionId, release, 'full-only', stubRegistry,  stubRegistryPath, variant);
    formattedContents.variant = variant;

    // architecture property could be a single string, an array, or an object of arrays by variant
    let architectures = configUtils.getBuildSettings(definitionId).architectures || ['linux/amd64'];
    if (!Array.isArray(architectures)) {
        architectures = architectures[variant];
    }
    formattedContents.architectures = architectures.reduce((prev, current, index) => index > 0 ? `${prev}, ${current}` : current, '');
    return releaseNotesVariantPartTemplate(formattedContents);
}

// Return all contents as an object of formatted values
function getFormattedContents(contents, contentFormatter) {
    let formattedContents = {};
    for (let contentType in contents) {
        formattedContents[contentType] = getFormattedContent(contents[contentType], contentFormatter[contentType]);
    }    
    return formattedContents;
}

function getFormattedContent(content, formatterFn) {
    if (!formatterFn || !content) {
        return null;
    }
    if(!Array.isArray(content)) {
        return formatterFn(content);
    }
    return content.reduce((prev, next) => {
        const formattedContent = formatterFn(next);
        if(formattedContent) {
            prev.push(formattedContent);
        }
        return prev;
    }, []);    
}

module.exports = {
    generateImageInformationFiles: generateImageInformationFiles
}
