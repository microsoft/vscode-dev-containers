/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

const path = require('path');
const jsonc = require('jsonc').jsonc;
const asyncUtils = require('./utils/async');
const configUtils = require('./utils/config');
const prep = require('./prep');

const imageLabelPrefix = configUtils.getConfig('imageLabelPrefix', 'com.microsoft.vscode.devcontainers');

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

    // Use or create a buildx / buildkit "builder" that using the docker-container driver which internally 
    // uses QEMU to emulate different architectures for cross-platform builds. Setting up a separate
    // builder avoids problems with the default config being different otherwise altered. It also can
    // be tweaked down the road to use a different driver like using separate machines per architecture.
    // See https://docs.docker.com/engine/reference/commandline/buildx_create/
    console.log('(*) Setting up builder...');
    const builders = await asyncUtils.exec('docker buildx ls');
    if(builders.indexOf('vscode-dev-containers') < 0) {
        await asyncUtils.spawn('docker', ['buildx', 'create', '--use', '--name', 'vscode-dev-containers']);
    } else {
        await asyncUtils.spawn('docker', ['buildx', 'use', 'vscode-dev-containers']);
    }
    // This step sets up the QEMU emulators for cross-platform builds. See https://github.com/docker/buildx#building-multi-platform-images
    await asyncUtils.spawn('docker', ['run', '--privileged', '--rm', 'tonistiigi/binfmt', '--install', 'all']);

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
        throw `Definition ${definitionId} does not exist! Invalid path: ${definitionPath}`;
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
            const buildSettings = configUtils.getBuildSettings(definitionId);
            let architectures = buildSettings.architectures;
            switch (typeof architectures) {
                case 'string': architectures = [architectures]; break;
                case 'object': if (!Array.isArray(architectures)) { architectures = architectures[variant]; } break;
                case 'undefined': architectures = ['linux/amd64']; break;
            }
            console.log(`(*) Target image architectures: ${architectures.reduce((prev, current) => prev += `\n     ${current}`, '')}`);
            let localArchitecture = process.arch;
            switch(localArchitecture) {
                case 'arm': localArchitecture = 'linux/arm/v7'; break;
                case 'aarch32': localArchitecture = 'linux/arm/v7'; break;
                case 'aarch64': localArchitecture = 'linux/arm64'; break;
                case 'x64': localArchitecture = 'linux/amd64'; break;
                case 'x32': localArchitecture = 'linux/386'; break;
                default: localArchitecture = `linux/${localArchitecture}`; break;
            }
            console.log(`(*) Local architecture: ${localArchitecture}`);
            if (!pushImages) {
                console.log(`(*) Push disabled: Only building local architecture (${localArchitecture}).`);
            }
            if (replaceImage || !await isDefinitionVersionAlreadyPublished(definitionId, release, registry, registryPath, variant)) {
                const context = devContainerJson.build ? devContainerJson.build.context || '.' : devContainerJson.context || '.';
                const workingDir = path.resolve(dotDevContainerPath, context);
                // Add tags to buildx command params
                const buildParams = versionTags.reduce((prev, current) => prev.concat(['-t', current]), []);
                // Note: build.args in devcontainer.json is intentionally ignored so you can vary image contents and defaults as needed
                // Add VARIANT --build-arg if applicable
                if(variant) {
                    buildParams.push('--build-arg', `VARIANT=${variant}`);
                }
                // Generate list of --build-arg values if applicable
                for (let buildArg in buildSettings.buildArgs || {}) {
                    buildParams.push('--build-arg', `${buildArg}=${buildSettings.buildArgs[buildArg]}`);
                }
                // Generate list of variant specific --build-arg values if applicable
                if (buildSettings.variantBuildArgs) {
                    for (let buildArg in buildSettings.variantBuildArgs[variant] || {}) {
                        buildParams.push('--build-arg', `${buildArg}=${buildSettings.variantBuildArgs[variant][buildArg]}`);
                    }
                }
                const spawnOpts = { stdio: 'inherit', cwd: workingDir, shell: true };
                await asyncUtils.spawn('docker', [
                        'buildx',
                        'build',
                        workingDir,
                        '-f', dockerFilePath, 
                        '--label', `version=${prepResult.meta.version}`,
                        `--label`, `${imageLabelPrefix}.id=${prepResult.meta.definitionId}`,
                        '--label', `${imageLabelPrefix}.variant=${prepResult.meta.variant}`,
                        '--label', `${imageLabelPrefix}.release=${prepResult.meta.gitRepositoryRelease}`,
                        '--label', `${imageLabelPrefix}.source=${prepResult.meta.gitRepository}`,
                        '--label', `${imageLabelPrefix}.timestamp='${prepResult.meta.buildTimestamp}'`,
                        '--builder', 'vscode-dev-containers',
                        '--progress', 'plain',
                        '--platform', pushImages ? architectures.reduce((prev, current) => prev + ',' + current, '').substring(1) : localArchitecture,
                        pushImages ? '--push' : '--load',
                        ...buildParams
                    ], spawnOpts);
                if (!pushImages) {
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
