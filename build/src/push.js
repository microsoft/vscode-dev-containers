/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

const path = require('path');
const jsonc = require('jsonc').jsonc;
const asyncUtils = require('./utils/async');
const configUtils = require('./utils/config');
const prep = require('./prep');

async function push(repo, release, updateLatest, registry, registryPath, stubRegistry,
    stubRegistryPath, pushImages, prepOnly, definitionsToSkip, page, pageTotal, replaceImages, definitionId) {

    // Optional argument defaults
    prepOnly = typeof prepOnly === 'undefined' ? false : prepOnly;
    pushImages = typeof pushImages === 'undefined' ? true : pushImages;
    page = page || 1;
    pageTotal = pageTotal || 1;
    stubRegistry = stubRegistry || registry;
    stubRegistryPath = stubRegistryPath || registryPath;
    definitionsToSkip = definitionsToSkip || [];

    // Always replace images when building and pushing the "dev" tag
    replaceImages = (configUtils.getVersionFromRelease(release, definitionId) == 'dev') || replaceImages;

    // Stage content
    const stagingFolder = await configUtils.getStagingFolder(release);
    await configUtils.loadConfig(stagingFolder);

    // Build and push subset of images
    const definitionsToPush = definitionId ? [definitionId] : configUtils.getSortedDefinitionBuildList(page, pageTotal, definitionsToSkip);
    await asyncUtils.forEach(definitionsToPush, async (currentDefinitionId) => {
        console.log(`**** Pushing ${currentDefinitionId} ${release} ****`);
        await pushImage(
            currentDefinitionId, repo, release, updateLatest, registry, registryPath, stubRegistry, stubRegistryPath, prepOnly, pushImages, replaceImages);
    });

    return stagingFolder;
}

async function pushImage(definitionId, repo, release, updateLatest,
    registry, registryPath, stubRegistry, stubRegistryPath, prepOnly, pushImages, replaceImage) {
    const definitionPath = configUtils.getDefinitionPath(definitionId);
    const dotDevContainerPath = path.join(definitionPath, '.devcontainer');
    // Use base.Dockerfile for image build if found, otherwise use Dockerfile
    const dockerFileExists = await asyncUtils.exists(path.join(dotDevContainerPath, 'Dockerfile'));
    const baseDockerFileExists = await asyncUtils.exists(path.join(dotDevContainerPath, 'base.Dockerfile'));
    const dockerFilePath = path.join(dotDevContainerPath, `${baseDockerFileExists ? 'base.' : ''}Dockerfile`);

    // Make sure there's a Dockerfile present
    if (!await asyncUtils.exists(dockerFilePath)) {
        throw `Invalid path ${dockerFilePath}`;
    }

    // Look for context in devcontainer.json and use it to build the Dockerfile
    console.log('(*) Reading devcontainer.json...');
    const devContainerJsonPath = path.join(dotDevContainerPath, 'devcontainer.json');
    const devContainerJsonRaw = await asyncUtils.readFile(devContainerJsonPath);
    const devContainerJson = jsonc.parse(devContainerJsonRaw);

    // Process variants in reverse order to be sure the first one is tagged as "latest" if appropriate
    const variants = configUtils.getVariants(definitionId) || [null];
    for (let i = variants.length - 1; i > -1; i--) {
        const variant = variants[i];

        // Update common setup script download URL, SHA, parent tag if applicable
        console.log(`(*) Prep Dockerfile for ${definitionId} ${variant ? 'variant "' + variant + '"' : ''}...`);
        const prepResult = await prep.prepDockerFile(dockerFilePath,
            definitionId, repo, release, registry, registryPath, stubRegistry, stubRegistryPath, true, variant);

        if (prepOnly) {
            console.log(`(*) Skipping build and push to registry.`);
        } else {
            if (prepResult.shouldFlattenBaseImage) {
                console.log(`(*) Flattening base image...`);
                await flattenBaseImage(prepResult.baseImageTag, prepResult.flattenedBaseImageTag, pushImages);
            }

            // Build image
            console.log(`(*) Building image...`);
            // Determine tags to use
            const versionTags = configUtils.getTagList(definitionId, release, updateLatest, registry, registryPath, variant);
            console.log(`(*) Tags:${versionTags.reduce((prev, current) => prev += `\n     ${current}`, '')}`);

            if (replaceImage || !await isDefinitionVersionAlreadyPublished(definitionId, release, registry, registryPath, variant)) {
                const context = devContainerJson.build ? devContainerJson.build.context || '.' : devContainerJson.context || '.';
                const workingDir = path.resolve(dotDevContainerPath, context);
                // Note: build.args in devcontainer.json is intentionally ignored so you can vary image contents and defaults as needed
                const buildParams = (variant ? ['--build-arg', `VARIANT=${variant}`] : [])
                    .concat(versionTags.reduce((prev, current) => prev.concat(['-t', current]), []));
                const spawnOpts = { stdio: 'inherit', cwd: workingDir, shell: true };
                await asyncUtils.spawn('docker', ['build', workingDir, '-f', dockerFilePath].concat(buildParams), spawnOpts);

                // Push
                if (pushImages) {
                    console.log(`(*) Pushing...`);
                    await asyncUtils.forEach(versionTags, async (versionTag) => {
                        await asyncUtils.spawn('docker', ['push', versionTag], spawnOpts);
                    });
                } else {
                    console.log(`(*) Skipping push to registry.`);
                }
            } else {
                console.log(`(*) Version already published. Skipping.`);
            }

        }
    }

    // If base.Dockerfile found, update stub/devcontainer.json, otherwise create - just use the default (first) variant if one exists
    if (baseDockerFileExists && dockerFileExists) {
        await prep.updateStub(
            dotDevContainerPath, definitionId, repo, release, baseDockerFileExists, stubRegistry, stubRegistryPath);
        console.log('(*) Updating devcontainer.json...');
        await asyncUtils.writeFile(devContainerJsonPath, devContainerJsonRaw.replace('"base.Dockerfile"', '"Dockerfile"'));
        console.log('(*) Removing base.Dockerfile...');
        await asyncUtils.rimraf(dockerFilePath);
    } else {
        await prep.createStub(
            dotDevContainerPath, definitionId, repo, release, baseDockerFileExists, stubRegistry, stubRegistryPath);
    }

    console.log('(*) Done!\n');
}

async function flattenBaseImage(baseImageTag, flattenedBaseImageTag, pushImages) {
    const flattenedImageCaptureGroups = /([^\/]+)\/(.+):(.+)/.exec(flattenedBaseImageTag);
    if (await isImageAlreadyPublished(flattenedImageCaptureGroups[1], flattenedImageCaptureGroups[2], flattenedImageCaptureGroups[3])) {
        console.log('(*) Flattened base image already published.')
        return;
    }

    // Flatten
    const processOpts = { stdio: 'inherit', shell: true };
    console.log('(*) Preparing base image...');
    await asyncUtils.spawn('docker', ['run', '-d', '--name', 'vscode-dev-containers-build-flatten', baseImageTag, 'bash'], processOpts);
    const containerInspectOutput = await asyncUtils.spawn('docker', ['inspect', 'vscode-dev-containers-build-flatten'], { shell: true, stdio: 'pipe' });
    console.log('(*) Flattening (this could take a while)...');
    const config = JSON.parse(containerInspectOutput)[0].Config;
    const envString = config.Env.reduce((prev, current) => prev + ' ' + current, '');
    const importArgs = `-c 'ENV ${envString}' -c 'ENTRYPOINT ${JSON.stringify(config.Entrypoint)}' -c 'CMD ${JSON.stringify(config.Cmd)}'`;
    await asyncUtils.exec(`docker export vscode-dev-containers-build-flatten | docker import ${importArgs} - ${flattenedBaseImageTag}`, processOpts);
    await asyncUtils.spawn('docker', ['container', 'rm', '-f', 'vscode-dev-containers-build-flatten'], processOpts);

    // Push if enabled
    if (pushImages) {
        console.log('(*) Pushing...');
        await asyncUtils.spawn('docker', ['push', flattenedBaseImageTag], processOpts);
    } else {
        console.log('(*) Skipping push.');
    }
}

async function isDefinitionVersionAlreadyPublished(definitionId, release, registry, registryPath, variant) {
    // See if image already exists
    const tagsToCheck = configUtils.getTagList(definitionId, release, false, registry, registryPath, variant);
    const tagParts = tagsToCheck[0].split(':');
    const registryName = registry.replace(/\..*/, '');
    return await isImageAlreadyPublished(registryName, tagParts[0].replace(/[^\/]+\//, ''), tagParts[1]);
}

async function isImageAlreadyPublished(registryName, repositoryName, tagName) {
    registryName = registryName.replace(/\.azurecr\.io.*/, '');
    // Check if repository exists
    const repositoriesOutput = await asyncUtils.spawn('az', ['acr', 'repository', 'list', '--name', registryName], { shell: true, stdio: 'pipe' });
    const repositories = JSON.parse(repositoriesOutput);
    if (repositories.indexOf(repositoryName) < 0) {
        console.log('(*) Repository does not exist. Image version has not been published yet.')
        return false;
    }

    // Assuming repository exists, check if tag exists
    const tagListOutput = await asyncUtils.spawn('az', ['acr', 'repository', 'show-tags',
        '--name', registryName,
        '--repository', repositoryName,
        '--query', `"[?@=='${tagName}']"`
    ], { shell: true, stdio: 'pipe' });
    const tagList = JSON.parse(tagListOutput);
    if (tagList.length > 0) {
        console.log('(*) Image version has already been published.')
        return true;
    }
    console.log('(*) Image version has not been published yet.')
    return false;
}

module.exports = {
    push: push
}
