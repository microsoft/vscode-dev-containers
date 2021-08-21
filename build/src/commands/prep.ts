/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as path from 'path';
import * as asyncUtils from '../utils/async';
import { getConfig, shouldFlattenDefinitionBaseImage } from '../utils/config';
import { Definition } from '../domain/definition';
import { CommonParams } from '../domain/common';
import * as definitionFactory from '../domain/definition-factory';
import mkdirp from 'mkdirp';
import * as glob from 'glob';
import * as handlebars from 'handlebars';

interface DefinitionMetadata {
    version: string;
    definitionId: string;
    variant?: string;
    gitRepository: string;
    gitRepositoryRelease: string;
    contentsUrl: string;
    buildTimestamp: string;
}

interface PrepResult {
    shouldFlattenBaseImage: boolean;
    baseImageTag: string;
    flattenedBaseImageTag: string;
    devContainerDockerfileModified: string;
    meta: DefinitionMetadata;
}

let metaEnvTemplate: handlebars.TemplateDelegate;

const scriptSHAMap = new Map<string, string>();

const dockerFilePreamble = getConfig('dockerFilePreamble');
const scriptLibraryFolder = getConfig('scriptLibraryFolder', 'script-library');
const scriptLibraryFolderInDefinition = getConfig('scriptLibraryFolderInDefinition', 'library-scripts');

const repositoryUrlPrefix = getConfig('repositoryUrlPrefix', 'https://github.com');
const historyUrlBranch = getConfig('historyUrlPathPrefix', 'main');
const historyFolder = getConfig('historyFolder', 'history');
const containersPathInRepo = getConfig('containersPathInRepo', 'containers');

// Prepares dockerfile for building or packaging
export async function prepDockerFile(definition: Definition, params: CommonParams, isForBuild: boolean = false, variant?: string) {
    const release = params.release;
    // Use exact version of building, MAJOR if not
    const version = isForBuild ? definition.getVersionForRelease(release) : definition.majorVersionPartForRelease(release);

    // Create initial result object 
    const prepResult: PrepResult = {
        shouldFlattenBaseImage: false,
        baseImageTag: '',
        flattenedBaseImageTag: '',
        devContainerDockerfileModified: await updateScriptSources(definition, params, !isForBuild, true),
        meta: {
            version: version,
            definitionId: definition.id,
            variant: variant,
            gitRepository: `${repositoryUrlPrefix}/${params.githubRepo}`,
            gitRepositoryRelease: release,
            contentsUrl: `${repositoryUrlPrefix}/${params.githubRepo}/tree/${historyUrlBranch}/${containersPathInRepo}/${definition.id}/${historyFolder}/${version}.md`,
            buildTimestamp: `${new Date().toUTCString()}`
        }
    };

    // Copy any scripts from the script library, add meta.env into the appropriate definition specific folder
    await copyLibraryScriptsAndSetMeta(definition, isForBuild, prepResult.meta);

    if (isForBuild) {
        // If building, update FROM to target registry and version if definition has a parent
        const parentTag = definition.getParentImageTagForRelease(version, params.registry, params.repository, variant);
        if (parentTag) {
            prepResult.devContainerDockerfileModified = replaceFrom(prepResult.devContainerDockerfileModified, `FROM ${parentTag}`);
        }

        prepResult.shouldFlattenBaseImage = shouldFlattenDefinitionBaseImage(definition.id);
        if (prepResult.shouldFlattenBaseImage) {
            // Determine base image
            const baseImageFromCaptureGroups = /FROM\s+(.+):([^\s\n]+)?/.exec(prepResult.devContainerDockerfileModified);
            if(!baseImageFromCaptureGroups || baseImageFromCaptureGroups.length < 2) {
                throw new Error(`Unable to find base image and tag in Dockerfile for ${definition.id}`);
            }
            let repository = baseImageFromCaptureGroups[1];
            if (variant) {
                repository = repository.replace('${VARIANT}', variant).replace('$VARIANT', variant);
            }
            const tagName = (baseImageFromCaptureGroups.length > 2 && variant) ?
                baseImageFromCaptureGroups[2].replace('${VARIANT}', variant).replace('$VARIANT', variant) :
                null;
            prepResult.baseImageTag = repository + (tagName ? ':' + tagName : '');

            // Create tag for flattened image
            const registrySlashIndex = repository.indexOf('/');
            if (registrySlashIndex > -1) {
                repository = repository.substring(registrySlashIndex + 1);
            }
            prepResult.flattenedBaseImageTag = `${params.registry}/${repository}:${tagName ? tagName + '-' : ''}flattened`;

            // Modify Dockerfile contents to use flattened image tag
            prepResult.devContainerDockerfileModified = replaceFrom(prepResult.devContainerDockerfileModified, `FROM ${prepResult.flattenedBaseImageTag}`);
        }
    } else {
        // Otherwise update any Dockerfiles that refer to an un-versioned tag of another dev container
        // to the MAJOR version from this release.
        const expectedRegistry = getConfig('stubRegistry', 'mcr.microsoft.com');
        const expectedRepository = getConfig('stubRegistryPath', 'vscode/devcontainers');
        const fromCaptureGroups = new RegExp(`FROM\\s+(${expectedRegistry}/${expectedRepository}/.+:.+)`).exec(prepResult.devContainerDockerfileModified);
        if (fromCaptureGroups && fromCaptureGroups.length > 0) {
            const fromDefinitionTag = definitionFactory.getUpdatedImageTag(
                fromCaptureGroups[1],
                expectedRegistry,
                expectedRepository,
                version,
                params.stubRegistry,
                params.stubRepository,
                variant);
            prepResult.devContainerDockerfileModified = prepResult.devContainerDockerfileModified.replace(fromCaptureGroups[0], `FROM ${fromDefinitionTag}`);
        }
    }

    definition.writeDockerfile(prepResult.devContainerDockerfileModified, !isForBuild);
    return prepResult;
}

export async function updateUserDockerfile(definition: Definition, params: CommonParams) {
    console.log('(*) Updating user Dockerfile...');
    const devContainerImageVersion = definition.majorVersionPartForRelease(params.release);
    let fromSection = `# ${dockerFilePreamble}https://github.com/${params.githubRepo}/tree/${params.release}/${definition.relativePath}/.devcontainer/${definition.hasBaseDockerfile ? 'base.' : ''}Dockerfile\n\n`;
    // The VARIANT arg allows this value to be set from devcontainer.json, handle it if found
    const userDockerfile = await definition.readDockerfile(true);
    if (/ARG\s+VARIANT\s*=/.exec(userDockerfile) !== null) {
        const tagWithVariant = definition.getImageTagsForRelease(devContainerImageVersion, params.registry, params.repository, '${VARIANT}')[0];
        // Handle scenario where "# [Choice]" comment exists
        const choiceCaptureGroup=/(#\s+\[Choice\].+\n)ARG\s+VARIANT\s*=/.exec(userDockerfile);
        if (choiceCaptureGroup) {
            fromSection += choiceCaptureGroup[1];
        }
        if(definition.variants) {
            fromSection += `ARG VARIANT="${definition.variants[0]}"\nFROM ${tagWithVariant}`;
        }
    } else {
        const imageTag = definition.getTagList(params.release, 'major', params.registry, params.repository)[0];
        fromSection += `FROM ${imageTag}`;
    }

    definition.writeDockerfile(replaceFrom(userDockerfile, fromSection), true);
}

export async function updateConfigForRelease(definition: Definition, params: CommonParams) {
    // Look for context in devcontainer.json and use it to build the Dockerfile
    console.log(`(*) Making version specific updates to ${definition.id}...`);
    const devContainerJsonModified =
        `// ${getConfig('devContainerJsonPreamble')}https://github.com/${params.githubRepo}/tree/${params.release}/${definition.relativePath}\n` +
        definition.devcontainerJsonString;
    await definition.updateDevcontainerJson(devContainerJsonModified);
    await prepDockerFile(definition, params, false);
}

// Replace script URLs and generate SHAs if applicable
async function updateScriptSources(definition: Definition, params: CommonParams, userDockerfile: boolean = false, updateScriptSha: boolean = true) {
    let devContainerDockerfileModified = await definition.readDockerfile(userDockerfile);
    const scriptArgs = /ARG\s+.+_SCRIPT_SOURCE/.exec(devContainerDockerfileModified) || [];
    await asyncUtils.forEach(scriptArgs, async (scriptArg: string) => {
        // Replace script URL and generate SHA if applicable
        const scriptCaptureGroups = new RegExp(`${scriptArg}\\s*=\\s*"(.+)/${scriptLibraryFolder.replace('.', '\\.')}/(.+)"`).exec(devContainerDockerfileModified);
        if (scriptCaptureGroups) {
            console.log(`(*) Script library source found.`);
            const scriptName = scriptCaptureGroups[2];
            const scriptSource = `https://raw.githubusercontent.com/${params.githubRepo}/${params.release}/${scriptLibraryFolder}/${scriptName}`;
            console.log(`    Updated script source URL: ${scriptSource}`);
            let sha = scriptSHAMap.get(scriptName);
            if (updateScriptSha && typeof sha === 'undefined') {
                const scriptRaw = await asyncUtils.getUrlAsString(scriptSource);
                sha = await asyncUtils.shaForString(scriptRaw);
                scriptSHAMap.set(scriptName, sha);
            }
            console.log(`    Script SHA: ${sha}`);
            const shaArg = scriptArg.replace('_SOURCE', '_SHA');
            devContainerDockerfileModified = devContainerDockerfileModified
                .replace(new RegExp(`${scriptArg}\\s*=\\s*".+"`), `${scriptArg}="${scriptSource}"`)
                .replace(new RegExp(`${shaArg}\\s*=\\s*".+"`), `${shaArg}="${updateScriptSha ? sha : 'dev-mode'}"`);
        }
    })

    return devContainerDockerfileModified;
}

// Update all script URLS in the entire repo (not staging folder)
export async function updateAllScriptSourcesInRepo(params: CommonParams, updateScriptSha: boolean = true) {
    // Update script versions in definition Dockerfiles for release
    const allDefinitions = definitionFactory.getAllDefinitions(true);
    for (let [, definition] of allDefinitions) {
        // Update base Dockerfile if one exists
        if(definition.hasBaseDockerfile) {
            const dockerfileModified = await updateScriptSources(definition, params, false, updateScriptSha);
            definition.writeDockerfile(dockerfileModified, false);
        }
        // Update user definitions
        const dockerfileModified = await updateScriptSources(definition, params, true, updateScriptSha);
        definition.writeDockerfile(dockerfileModified, true);
        await copyLibraryScriptsAndSetMeta(definition);
    }
}

// Copy contents of script library to folder, meta.env file if specified and building
async function copyLibraryScriptsAndSetMeta(definition: Definition, isForBuild: boolean = false, meta?: DefinitionMetadata) {
    if (definition.hasLibraryScripts) {
        await asyncUtils.forEach(await asyncUtils.readdir(definition.libraryScriptsPath), async (script: string) => {
            // Only copy files that end in .sh
            if (path.extname(script) !== '.sh') {
                return;
            }
            const possibleScriptSource = path.join(__dirname, '..', '..', scriptLibraryFolder, script);
            if (await asyncUtils.exists(possibleScriptSource)) {
                const targetScriptPath = path.join(definition.libraryScriptsPath, script);
                console.log(`(*) Copying ${script} to ${definition.libraryScriptsPath}...`);
                await asyncUtils.copyFile(possibleScriptSource, targetScriptPath);
            }
        });
    }
    if (isForBuild && meta) {
        // Write meta.env for use by scripts
        metaEnvTemplate = metaEnvTemplate || handlebars.compile(await asyncUtils.readFile(path.join(__dirname, '..', 'assets', 'meta.env')));
        mkdirp(definition.libraryScriptsPath);
        await asyncUtils.writeFile(path.join(definition.libraryScriptsPath, 'meta.env'), metaEnvTemplate(meta));
    }
}

// For CI of the script library folder
export async function copyLibraryScriptsForAllDefinitions() {
    const devcontainerFolders = glob.sync(`${path.resolve(__dirname, '..', '..')}/+(containers|container-templates|repository-containers)/**/.devcontainer`);
    await asyncUtils.forEach(devcontainerFolders, async (folder: string) => {
        console.log(`(*) Checking ${path.basename(path.resolve(folder, '..'))} for ${scriptLibraryFolderInDefinition} folder...`);
        const definition = definitionFactory.getDefinition(folder);
        await copyLibraryScriptsAndSetMeta(definition);
    });
}

function replaceFrom(dockerFileContents: string, newFromSection: string) {
    return dockerFileContents.replace(/(#\s+\[Choice\].+\n)?(ARG\s+VARIANT\s*=\s*.+\n)?(FROM\s+[^\s\n]+)/, newFromSection);
}
