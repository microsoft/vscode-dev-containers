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
    let devContainerDockerfileModified = await updateScriptSources(devContainerDockerfileRaw, repo, release, true);

    if (isForBuild) {
        // If building, update FROM to target registry and version if definition has a parent
        const parentTag = configUtils.getParentTagForVersion(definitionId, version, registry, registryPath, variant);
        if (parentTag) {
            devContainerDockerfileModified = devContainerDockerfileModified.replace(/FROM\s+.+:.+/, `FROM ${parentTag}`)
        }
    } else {
        // Otherwise update any Dockerfiles that refer to an un-versioned tag of another dev container
        // to the MAJOR version from this release.
        const expectedRegistry = configUtils.getConfig('stubRegistry', 'mcr.microsoft.com');
        const expectedRegistryPath = configUtils.getConfig('stubRegistryPath', 'vscode/devcontainers');
        const fromCaptureGroups = new RegExp(`FROM ((${registry}|${expectedRegistry})/(${registryPath}|${expectedRegistryPath})/.+:.+)`).exec(devContainerDockerfileRaw);
        if (fromCaptureGroups && fromCaptureGroups.length > 0) {
            const fromDefinitionTag = configUtils.getUpdatedTag(
                fromCaptureGroups[1], 
                fromCaptureGroups[2],
                fromCaptureGroups[3],
                version,
                stubRegistry,
                stubRegistryPath,
                variant);
            devContainerDockerfileModified = devContainerDockerfileModified
                .replace(fromCaptureGroups[0], `FROM ${fromDefinitionTag}`);
        }
    }

    await asyncUtils.writeFile(devContainerDockerfilePath, devContainerDockerfileModified)
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
    let fromSection = `# ${configUtils.getConfig('dockerFilePreamble')}\n` +
        `# https://github.com/${repo}/tree/${release}/${containersPathInRepo}/${definitionId}/.devcontainer/${baseDockerFileExists ? 'base.' : ''}Dockerfile\n`;
    // The VARIANT arg allows this value to be set from devcontainer.json, handle it if found
    if (/ARG\s+VARIANT\s*=/.exec(userDockerFile) !== null) {
        const variant = configUtils.getVariants(definitionId)[0];
        const tagWithVariant = configUtils.getTagsForVersion(definitionId, devContainerImageVersion, registry, registryPath, '${VARIANT}')[0];
        fromSection += `ARG VARIANT="${variant}"\nFROM ${tagWithVariant}`;
    } else {
        const imageTag = configUtils.getTagsForVersion(definitionId, devContainerImageVersion, registry, registryPath)[0];
        fromSection += `FROM ${imageTag}`;
    }

    return userDockerFile.replace(/(ARG\s+VARIANT\s*=\s*.+\n)?(FROM\s+.+\n)/, `${fromSection}\n`);
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

// Update script URL in a Dockerfile to be release specific (or not) and optionally update the SHA to lock to this version
async function updateScriptSourcesInDockerfile(devContainerDockerfilePath, repo, release, updateScriptSha) {
    const devContainerDockerfileRaw = await asyncUtils.readFile(devContainerDockerfilePath);
    const devContainerDockerfileModified = await updateScriptSources(devContainerDockerfileRaw, repo, release, updateScriptSha);
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
