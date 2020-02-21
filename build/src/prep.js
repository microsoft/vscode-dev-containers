/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

const path = require('path');
const asyncUtils = require('./utils/async');
const configUtils = require('./utils/config');

const scriptSHA = {};

const assetsPath = path.join(__dirname, '..', 'assets');
const stubPromises = {
    alpine: asyncUtils.readFile(path.join(assetsPath, 'alpine.Dockerfile')),
    debian: asyncUtils.readFile(path.join(assetsPath, 'debian.Dockerfile')),
    redhat: asyncUtils.readFile(path.join(assetsPath, 'redhat.Dockerfile'))
}

const containersPathInRepo = configUtils.getConfig('containersPathInRepo');
const scriptLibraryPathInRepo = configUtils.getConfig('scriptLibraryPathInRepo');

async function prepDockerFile(devContainerDockerfilePath, definitionId, repo, release, registry, registryPath, stubRegistry, stubRegistryPath, isForBuild, variant) {
    // Use exact version of building, MAJOR if not
    const version = isForBuild ? configUtils.getVersionFromRelease(release, definitionId) : configUtils.majorFromRelease(release, definitionId);

    // Read Dockerfile
    const devContainerDockerfileRaw = await asyncUtils.readFile(devContainerDockerfilePath);
    
    // Replace script URL and generate SHA if applicable
    let devContainerDockerfileModified = await updateScriptSource(devContainerDockerfileRaw, repo, release, true);

    if (isForBuild) {
        // If building, update FROM to target registry and version if definition has a parent
        const parentTag = configUtils.getParentTagForVersion(definitionId, version, registry, registryPath, variant);
        if (parentTag) {
            devContainerDockerfileModified = devContainerDockerfileModified.replace(/FROM .+:.+/, `FROM ${parentTag}`)
        }
    } else {
        // Otherwise update any Dockerfiles that refer to an un-versioned tag of another dev container
        // to the MAJOR version from this release.
        const expectedRegistry = configUtils.getConfig('stubRegistry', 'mcr.microsoft.com');
        const expectedRegistryPath = configUtils.getConfig('stubRegistryPath', 'vscode/devcontainers');
        const fromCaptureGroups = new RegExp(`FROM (${expectedRegistry}/${expectedRegistryPath}/.+:.+)`).exec(devContainerDockerfileRaw);
        if (fromCaptureGroups && fromCaptureGroups.length > 0) {
            const fromDefinitionTag = configUtils.getUpdatedTag(
                fromCaptureGroups[1], 
                expectedRegistry,
                expectedRegistryPath,
                version, 
                stubRegistry,
                stubRegistryPath);
            devContainerDockerfileModified = devContainerDockerfileModified
                .replace(fromCaptureGroups[0], `FROM ${fromDefinitionTag}`);
        }
    }

    await asyncUtils.writeFile(devContainerDockerfilePath, devContainerDockerfileModified)
}

function getFromSnippet(definitionId, imageTag, repo, release, baseDockerFileExists) {
    return `# ${configUtils.getConfig('dockerFilePreamble')}\n` +
        `# https://github.com/${repo}/tree/${release}/${containersPathInRepo}/${definitionId}/.devcontainer/${baseDockerFileExists ? 'base.' : ''}Dockerfile\n` +
        `FROM ${imageTag}`;
}

async function createStub(dotDevContainerPath, definitionId, repo, release, baseDockerFileExists, stubRegistry, stubRegistryPath) {
    const userDockerFilePath = path.join(dotDevContainerPath, 'Dockerfile');
    console.log('(*) Generating user Dockerfile...');
    const templateDockerfile = await configUtils.objectByDefinitionLinuxDistro(definitionId, stubPromises);
    const devContainerImageVersion = configUtils.majorFromRelease(release, definitionId);
    const imageTag = configUtils.getTagsForVersion(definitionId, devContainerImageVersion, stubRegistry, stubRegistryPath)[0];
    const userDockerFile = templateDockerfile.replace(
        'FROM REPLACE-ME', getFromSnippet(definitionId, imageTag, repo, release, baseDockerFileExists));
    await asyncUtils.writeFile(userDockerFilePath, userDockerFile);
}

async function updateStub(dotDevContainerPath, definitionId, repo, release, baseDockerFileExists, registry, registryPath) {
    console.log('(*) Updating user Dockerfile...');
    const userDockerFilePath = path.join(dotDevContainerPath, 'Dockerfile');
    const userDockerFile = await asyncUtils.readFile(userDockerFilePath);

    const devContainerImageVersion = configUtils.majorFromRelease(release, definitionId);
    const imageTag = configUtils.getTagsForVersion(definitionId, devContainerImageVersion, registry, registryPath)[0];
    const userDockerFileModified = userDockerFile.replace(/FROM .+:.+/,
        getFromSnippet(definitionId, imageTag, repo, release, baseDockerFileExists));
    await asyncUtils.writeFile(userDockerFilePath, userDockerFileModified);
}

async function updateConfigForRelease(definitionPath, definitionId, repo, release, registry, registryPath, stubRegistry, stubRegistryPath) {
    // Look for context in devcontainer.json and use it to build the Dockerfile
    console.log(`(*) Making version specific updates to ${definitionId}...`);
    const dotDevContainerPath = path.join(definitionPath, '.devcontainer');
    const devContainerJsonPath = path.join(dotDevContainerPath, 'devcontainer.json');
    const devContainerJsonRaw = await asyncUtils.readFile(devContainerJsonPath);
    const devContainerJsonModified =
        `// ${configUtils.getConfig('devContainerJsonPreamble')}\n// https://github.com/${repo}/tree/${release}/${containersPathInRepo}/${definitionId}\n` +
        devContainerJsonRaw;
    await asyncUtils.writeFile(devContainerJsonPath, devContainerJsonModified);

    // Replace version specific content in Dockerfile
    const dockerFilePath = path.join(dotDevContainerPath, 'Dockerfile');
    if (await asyncUtils.exists(dockerFilePath)) {
        await prepDockerFile(dockerFilePath, definitionId, repo, release, registry, registryPath, stubRegistry, stubRegistryPath, false);
    }
}

// Replace script URL and generate SHA if applicable
async function updateScriptSource(devContainerDockerfileRaw, repo, release, updateScriptSha) {
    updateScriptSha = typeof updateScriptSha === 'undefined' ? true : updateScriptSha;
    
    // Replace script URL and generate SHA if applicable
    const scriptCaptureGroups = new RegExp(`COMMON_SCRIPT_SOURCE="(.+)/${scriptLibraryPathInRepo.replace('.', '\\.')}/(.+)"`).exec(devContainerDockerfileRaw);
    if (scriptCaptureGroups) {
        console.log(`(*) Common script source found.`);
        const scriptName = scriptCaptureGroups[2];
        const scriptSource = `https://raw.githubusercontent.com/${repo}/${release}/${scriptLibraryPathInRepo}/${scriptName}`;
        console.log(`    New common script source URL: ${scriptSource}`);
        let sha = scriptSHA[scriptName];
        if (updateScriptSha && typeof sha === 'undefined') {
            const scriptRaw = await asyncUtils.getUrlAsString(scriptSource);
            sha = await asyncUtils.shaForString(scriptRaw);
            scriptSHA[scriptName] = sha;
        }
        console.log(`    Script SHA: ${sha}`);
        return devContainerDockerfileRaw
            .replace(/COMMON_SCRIPT_SHA=".+"/, `COMMON_SCRIPT_SHA="${updateScriptSha ? sha : 'dev-mode'}"`)
            .replace(/COMMON_SCRIPT_SOURCE=".+"/, `COMMON_SCRIPT_SOURCE="${scriptSource}"`);

    }
    return devContainerDockerfileRaw;
}

// Update script URL in a Dockerfile to be release specific (or not) and optionally update the SHA to lock to this version
async function updateScriptSourcesInDockerfile(devContainerDockerfilePath, repo, release, updateScriptSha) {
    const devContainerDockerfileRaw = await asyncUtils.readFile(devContainerDockerfilePath);
    const devContainerDockerfileModified = await updateScriptSource(devContainerDockerfileRaw, repo, release, updateScriptSha);
    await asyncUtils.writeFile(devContainerDockerfilePath, devContainerDockerfileModified);
}

// Update all script URLS in the entire repo (not staging folder)
async function updateAllScriptSourcesInRepo(repo, release, updateScriptSha) {
    const definitionFolder = path.join(__dirname, '..', '..', 'containers');
    // Update script versions in definition Dockerfiles for release
    const allDefinitions = await asyncUtils.readdir(definitionFolder);
    await asyncUtils.forEach(allDefinitions, async (currentDefinitionId) => {
        const dockerFileBasePath = path.join(definitionFolder, currentDefinitionId, '.devcontainer', 'base.Dockerfile');
        if (await asyncUtils.exists(dockerFileBasePath)) {
            console.log('(*) Looking for script source in base.Dockerfile for ${currentDefinitionId}.');
            await updateScriptSourcesInDockerfile(dockerFileBasePath, repo, release, updateScriptSha);
        }
        const dockerFilePath = path.join(definitionFolder, currentDefinitionId, '.devcontainer', 'Dockerfile');
        if (await asyncUtils.exists(dockerFilePath)) {
            console.log('(*) Looking for script source in Dockerfile for ${currentDefinitionId}.');
            await updateScriptSourcesInDockerfile(dockerFilePath, repo, release, updateScriptSha);
        }
    });
}

module.exports = {
    createStub: createStub,
    updateStub: updateStub,
    updateConfigForRelease: updateConfigForRelease,
    prepDockerFile: prepDockerFile,
    updateScriptSourcesInDockerfile: updateScriptSourcesInDockerfile,
    updateAllScriptSourcesInRepo: updateAllScriptSourcesInRepo
}
