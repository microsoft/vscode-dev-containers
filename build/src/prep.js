/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

const path = require('path');
const asyncUtils = require('./utils/async');
const configUtils = require('./utils/config');
const mkdirp = require('mkdirp');
const glob = require('glob');
const handlebars = require('handlebars');
let metaEnvTemplate;

const scriptSHA = {};

const assetsPath = path.join(__dirname, '..', 'assets');
const stubPromises = {
    alpine: asyncUtils.readFile(path.join(assetsPath, 'alpine.Dockerfile')),
    debian: asyncUtils.readFile(path.join(assetsPath, 'debian.Dockerfile')),
    redhat: asyncUtils.readFile(path.join(assetsPath, 'redhat.Dockerfile'))
}

const dockerFilePreamble = configUtils.getConfig('dockerFilePreamble');
const scriptLibraryPathInRepo = configUtils.getConfig('scriptLibraryPathInRepo');
const scriptLibraryFolderNameInDefinition = configUtils.getConfig('scriptLibraryFolderNameInDefinition');

const historyUrlPrefix = configUtils.getConfig('historyUrlPrefix');
const repositoryUrl = configUtils.getConfig('repositoryUrl');

// Prepares dockerfile for building or packaging
async function prepDockerFile(devContainerDockerfilePath, definitionId, repo, release, registry, registryPath, stubRegistry, stubRegistryPath, isForBuild, variant) {
    const devContainerJsonPath = path.dirname(devContainerDockerfilePath);

    // Read Dockerfile
    const devContainerDockerfileRaw = await asyncUtils.readFile(devContainerDockerfilePath);

    // Use exact version of building, MAJOR if not
    const version = isForBuild ? configUtils.getVersionFromRelease(release, definitionId) : configUtils.majorFromRelease(release, definitionId);

    // Create initial result object 
    const prepResult = {
        shouldFlattenBaseImage: false,
        baseImage: null,
        flattenedBaseImage: null,
        devContainerDockerfileModified: await updateScriptSources(devContainerDockerfileRaw, repo, release, true),
        meta: {
            version: version,
            definitionId: definitionId,
            variant: variant,
            gitRepository: repositoryUrl,
            gitRepositoryRelease: release,
            contentsUrl: `${historyUrlPrefix}${definitionId}/${configUtils.getConfig('historyFolderName', 'history')}/${version}.md`,
            buildTimestamp: `${new Date().toUTCString()}`
        }
    };

    // Copy any scripts from the script library, add meta.env into the appropriate definition specific folder
    await copyLibraryScriptsForDefinition(devContainerJsonPath, isForBuild, prepResult.meta);

    if (isForBuild) {
        // If building, update FROM to target registry and version if definition has a parent
        const parentTag = configUtils.getParentTagForVersion(definitionId, version, registry, registryPath, variant);
        if (parentTag) {
            prepResult.devContainerDockerfileModified = replaceFrom(prepResult.devContainerDockerfileModified, `FROM ${parentTag}`);
        }

        prepResult.shouldFlattenBaseImage = configUtils.shouldFlattenDefinitionBaseImage(definitionId);
        if (prepResult.shouldFlattenBaseImage) {
            // Determine base image
            const baseImageFromCaptureGroups = /FROM\s+(.+):([^\s\n]+)?/.exec(prepResult.devContainerDockerfileModified);
            let registryPath = baseImageFromCaptureGroups[1].replace('${VARIANT}', variant).replace('$VARIANT', variant);
            const tagName = (baseImageFromCaptureGroups.length > 2) ?
                baseImageFromCaptureGroups[2].replace('${VARIANT}', variant).replace('$VARIANT', variant) :
                null;
            prepResult.baseImageTag = registryPath + (tagName ? ':' + tagName : '');

            // Create tag for flattened image
            const registrySlashIndex = registryPath.indexOf('/');
            if (registrySlashIndex > -1) {
                registryPath = registryPath.substring(registrySlashIndex + 1);
            }
            prepResult.flattenedBaseImageTag = `${registry}/${registryPath}:${tagName ? tagName + '-' : ''}flattened`;

            // Modify Dockerfile contents to use flattened image tag
            prepResult.devContainerDockerfileModified = replaceFrom(prepResult.devContainerDockerfileModified, `FROM ${prepResult.flattenedBaseImageTag}`);
        }
    } else {
        // Otherwise update any Dockerfiles that refer to an un-versioned tag of another dev container
        // to the MAJOR version from this release.
        const expectedRegistry = configUtils.getConfig('stubRegistry', 'mcr.microsoft.com');
        const expectedRegistryPath = configUtils.getConfig('stubRegistryPath', 'vscode/devcontainers');
        const fromCaptureGroups = new RegExp(`FROM\\s+(${expectedRegistry}/${expectedRegistryPath}/.+:.+)`).exec(devContainerDockerfileRaw);
        if (fromCaptureGroups && fromCaptureGroups.length > 0) {
            const fromDefinitionTag = configUtils.getUpdatedTag(
                fromCaptureGroups[1],
                expectedRegistry,
                expectedRegistryPath,
                version,
                stubRegistry,
                stubRegistryPath,
                variant);
            prepResult.devContainerDockerfileModified = prepResult.devContainerDockerfileModified
                .replace(fromCaptureGroups[0], `FROM ${fromDefinitionTag}`);
        }
    }

    await asyncUtils.writeFile(devContainerDockerfilePath, prepResult.devContainerDockerfileModified);
    return prepResult;
}

async function createStub(dotDevContainerPath, definitionId, repo, release, baseDockerFileExists, stubRegistry, stubRegistryPath) {
    const userDockerFilePath = path.join(dotDevContainerPath, 'Dockerfile');
    console.log('(*) Generating user Dockerfile...');
    const templateDockerfile = await configUtils.objectByDefinitionLinuxDistro(definitionId, stubPromises);
    const userDockerFile = await processStub(templateDockerfile, definitionId, repo, release, baseDockerFileExists, stubRegistry, stubRegistryPath);
    await asyncUtils.writeFile(userDockerFilePath, userDockerFile);
}

async function updateStub(dotDevContainerPath, definitionId, repo, release, baseDockerFileExists, registry, registryPath) {
    console.log('(*) Updating user Dockerfile...');
    const userDockerFilePath = path.join(dotDevContainerPath, 'Dockerfile');
    const userDockerFile = await asyncUtils.readFile(userDockerFilePath);
    const userDockerFileModified = await processStub(userDockerFile, definitionId, repo, release, baseDockerFileExists, registry, registryPath);
    await asyncUtils.writeFile(userDockerFilePath, userDockerFileModified);
}

async function processStub(userDockerFile, definitionId, repo, release, baseDockerFileExists, registry, registryPath) {
    const devContainerImageVersion = configUtils.majorFromRelease(release, definitionId);
    const relativePath = configUtils.getDefinitionPath(definitionId, true);
    let fromSection = `# ${dockerFilePreamble}https://github.com/${repo}/tree/${release}/${relativePath}/.devcontainer/${baseDockerFileExists ? 'base.' : ''}Dockerfile\n\n`;
    // The VARIANT arg allows this value to be set from devcontainer.json, handle it if found
    if (/ARG\s+VARIANT\s*=/.exec(userDockerFile) !== null) {
        const variant = configUtils.getVariants(definitionId)[0];
        const tagWithVariant = configUtils.getTagsForVersion(definitionId, devContainerImageVersion, registry, registryPath, '${VARIANT}')[0];
        // Handle scenario where "# [Choice]" comment exists
        const choiceCaptureGroup=/(#\s+\[Choice\].+\n)ARG\s+VARIANT\s*=/.exec(userDockerFile);
        if (choiceCaptureGroup) {
            fromSection += choiceCaptureGroup[1];
        }
        fromSection += `ARG VARIANT="${variant}"\nFROM ${tagWithVariant}`;
    } else {
        const imageTag = configUtils.getTagsForVersion(definitionId, devContainerImageVersion, registry, registryPath)[0];
        fromSection += `FROM ${imageTag}`;
    }

    return replaceFrom(userDockerFile, fromSection);
}

async function updateConfigForRelease(definitionId, repo, release, registry, registryPath, stubRegistry, stubRegistryPath) {
    // Look for context in devcontainer.json and use it to build the Dockerfile
    console.log(`(*) Making version specific updates to ${definitionId}...`);
    const definitionPath = configUtils.getDefinitionPath(definitionId, false);
    const relativePath = configUtils.getDefinitionPath(definitionId, true);
    const dotDevContainerPath = path.join(definitionPath, '.devcontainer');
    const devContainerJsonPath = path.join(dotDevContainerPath, 'devcontainer.json');
    const devContainerJsonRaw = await asyncUtils.readFile(devContainerJsonPath);
    const devContainerJsonModified =
        `// ${configUtils.getConfig('devContainerJsonPreamble')}https://github.com/${repo}/tree/${release}/${relativePath}\n` +
        devContainerJsonRaw;
    await asyncUtils.writeFile(devContainerJsonPath, devContainerJsonModified);

    // Replace version specific content in Dockerfile
    const dockerFilePath = path.join(dotDevContainerPath, 'Dockerfile');
    if (await asyncUtils.exists(dockerFilePath)) {
        await prepDockerFile(dockerFilePath, definitionId, repo, release, registry, registryPath, stubRegistry, stubRegistryPath, false);
    }
}

// Replace script URLs and generate SHAs if applicable
async function updateScriptSources(devContainerDockerfileRaw, repo, release, updateScriptSha) {
    updateScriptSha = typeof updateScriptSha === 'undefined' ? true : updateScriptSha;
    let devContainerDockerfileModified = devContainerDockerfileRaw;

    const scriptArgs = /ARG\s+.+_SCRIPT_SOURCE/.exec(devContainerDockerfileRaw) || [];
    await asyncUtils.forEach(scriptArgs, async (scriptArg) => {
        // Replace script URL and generate SHA if applicable
        const scriptCaptureGroups = new RegExp(`${scriptArg}\\s*=\\s*"(.+)/${scriptLibraryPathInRepo.replace('.', '\\.')}/(.+)"`).exec(devContainerDockerfileModified);
        if (scriptCaptureGroups) {
            console.log(`(*) Script library source found.`);
            const scriptName = scriptCaptureGroups[2];
            const scriptSource = `https://raw.githubusercontent.com/${repo}/${release}/${scriptLibraryPathInRepo}/${scriptName}`;
            console.log(`    Updated script source URL: ${scriptSource}`);
            let sha = scriptSHA[scriptName];
            if (updateScriptSha && typeof sha === 'undefined') {
                const scriptRaw = await asyncUtils.getUrlAsString(scriptSource);
                sha = await asyncUtils.shaForString(scriptRaw);
                scriptSHA[scriptName] = sha;
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

// Update script files and URLs in a Dockerfile to be release specific (or not) and optionally update the SHA to lock to this version
async function updateScriptSourcesInDockerfile(devContainerDockerfilePath, repo, release, updateScriptSha) {
    const devContainerDockerfileRaw = await asyncUtils.readFile(devContainerDockerfilePath);
    const devContainerDockerfileModified = await updateScriptSources(devContainerDockerfileRaw, repo, release, updateScriptSha);
    await asyncUtils.writeFile(devContainerDockerfilePath, devContainerDockerfileModified);
    await copyLibraryScriptsForDefinition(path.dirname(devContainerDockerfilePath));
}

// Update all script URLS in the entire repo (not staging folder)
async function updateAllScriptSourcesInRepo(repo, release, updateScriptSha) {
    const definitionFolder = path.join(__dirname, '..', '..', 'containers');
    // Update script versions in definition Dockerfiles for release
    const allDefinitions = await asyncUtils.readdir(definitionFolder, { withFileTypes: true });
    await asyncUtils.forEach(allDefinitions, async (currentDefinition) => {
        if (!currentDefinition.isDirectory()) {
            return;
        }

        const dockerFileBasePath = path.join(definitionFolder, currentDefinition.name, '.devcontainer', 'base.Dockerfile');
        if (await asyncUtils.exists(dockerFileBasePath)) {
            console.log(`(*) Looking for script source in base.Dockerfile for ${currentDefinition.name}.`);
            await updateScriptSourcesInDockerfile(dockerFileBasePath, repo, release, updateScriptSha);
        }
        const dockerFilePath = path.join(definitionFolder, currentDefinition.name, '.devcontainer', 'Dockerfile');
        if (await asyncUtils.exists(dockerFilePath)) {
            console.log(`(*) Looking for script source in Dockerfile for ${currentDefinition.name}.`);
            await updateScriptSourcesInDockerfile(dockerFilePath, repo, release, updateScriptSha);
        }
    });
}

// Copy contents of script library to folder, meta.env file if specified and building
async function copyLibraryScriptsForDefinition(definitionDevContainerJsonFolder, isForBuild, meta) {
    const libraryScriptsFolder = path.join(definitionDevContainerJsonFolder, scriptLibraryFolderNameInDefinition);
    if (await asyncUtils.exists(libraryScriptsFolder)) {
        await asyncUtils.forEach(await asyncUtils.readdir(libraryScriptsFolder), async (script) => {
            // Only copy files that end in .sh
            if (path.extname(script) !== '.sh') {
                return;
            }
            const possibleScriptSource = path.join(__dirname, '..', '..', scriptLibraryPathInRepo, script);
            if (await asyncUtils.exists(possibleScriptSource)) {
                const targetScriptPath = path.join(libraryScriptsFolder, script);
                console.log(`(*) Copying ${script} to ${libraryScriptsFolder}...`);
                await asyncUtils.copyFile(possibleScriptSource, targetScriptPath);
            }
        });
    }
    if (isForBuild && meta) {
        // Write meta.env for use by scripts
        metaEnvTemplate = metaEnvTemplate || handlebars.compile(await asyncUtils.readFile(path.join(__dirname, '..', 'assets', 'meta.env')));
        mkdirp(libraryScriptsFolder);
        await asyncUtils.writeFile(path.join(libraryScriptsFolder, 'meta.env'), metaEnvTemplate(meta));
    }
}

// For CI of the script library folder
async function copyLibraryScriptsForAllDefinitions() {
    const devcontainerFolders = glob.sync(`${path.resolve(__dirname, '..', '..')}/+(containers|container-templates|repository-containers)/**/.devcontainer`);
    await asyncUtils.forEach(devcontainerFolders, async (folder) => {
        console.log(`(*) Checking ${path.basename(path.resolve(folder, '..'))} for ${scriptLibraryFolderNameInDefinition} folder...`);
        await copyLibraryScriptsForDefinition(folder);
    });
}

function replaceFrom(dockerFileContents, newFromSection) {
    return dockerFileContents.replace(/(#\s+\[Choice\].+\n)?(ARG\s+VARIANT\s*=\s*.+\n)?(FROM\s+[^\s\n]+)/, newFromSection);
}

module.exports = {
    createStub: createStub,
    updateStub: updateStub,
    updateConfigForRelease: updateConfigForRelease,
    prepDockerFile: prepDockerFile,
    copyLibraryScriptsForAllDefinitions: copyLibraryScriptsForAllDefinitions,
    updateScriptSourcesInDockerfile: updateScriptSourcesInDockerfile,
    updateAllScriptSourcesInRepo: updateAllScriptSourcesInRepo
}
