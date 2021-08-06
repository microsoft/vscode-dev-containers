/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as path from 'path';
import * as asyncUtils from './utils/async';
import * as configUtils from './utils/config';
import * as prep from './prep';
import { Definition } from './domain/definition';
import { Lookup, CommonParams } from './domain/common';
import { getSortedDefinitionBuildList, getDefinition } from './domain/definition-factory';

const imageLabelPrefix = configUtils.getConfig('imageLabelPrefix', 'com.microsoft.vscode.devcontainers');

export async function push(params: CommonParams, updateLatest: boolean = false, pushImages: boolean = true, prepOnly: boolean = false, definitionsToSkip: string[] = [], page: number = 1, pageTotal: number = 1, replaceImages: boolean = false, definitionId?: string) {

    // Always replace images when building and pushing the "dev" tag
    replaceImages = (configUtils.getVersionForRelease(params.release) == 'dev') || replaceImages;

    // Stage content
    const stagingFolder = await configUtils.getStagingFolder(params.release);
    await configUtils.loadConfig(stagingFolder);

    // Build and push subset of images
    const definitionsToPush = definitionId ? [getDefinition(definitionId)] : getSortedDefinitionBuildList(page, pageTotal, definitionsToSkip);
    await asyncUtils.forEach(definitionsToPush, async (currentDefinition: Definition) => {
        console.log(`**** Pushing ${currentDefinition.id} ${params.release} ****`);
        await pushImage(currentDefinition, params, updateLatest, prepOnly, pushImages, replaceImages);
    });

    return stagingFolder;
}

async function pushImage(definition: Definition, params: CommonParams, updateLatest, prepOnly, pushImages, replaceImage) {
    const dotDevContainerPath = path.join(definition.path, '.devcontainer');
    const dockerFilePath = await definition.getDockerfilePath();
    
    // Make sure there's a Dockerfile present
    if (!await asyncUtils.exists(dockerFilePath)) {
        throw `Invalid path ${dockerFilePath}`;
    }

    // Process variants in reverse order to be sure the first one is tagged as "latest" if appropriate
    const variants = definition.variants || [null];
    for (let i = variants.length - 1; i > -1; i--) {
        const variant = variants[i];

        // Update common setup script download URL, SHA, parent tag if applicable
        console.log(`(*) Prep Dockerfile for ${definition.id} ${variant ? 'variant "' + variant + '"' : ''}...`);
        const prepResult = await prep.prepDockerFile(definition, params, true, variant);

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
            const versionTags = definition.getTagList(params.release, updateLatest, params.registry, params.repository, variant);
            console.log(`(*) Tags:${versionTags.reduce((prev, current) => prev += `\n     ${current}`, '')}`);

            if (replaceImage || !await isDefinitionVersionAlreadyPublished(definition, params, variant)) {
                const context = definition.build ? definition.devcontainerJson.build.context || '.' : '.';
                const workingDir = path.resolve(dotDevContainerPath, context);
                // Note: build.args in devcontainer.json is intentionally ignored so you can vary image contents and defaults as needed
                const buildParams = (variant ? ['--build-arg', `VARIANT=${variant}`] : [])
                    .concat(versionTags.reduce((prev, current) => prev.concat(['-t', current]), []));
                const spawnOpts = { stdio: 'inherit', cwd: workingDir, shell: true };
                await asyncUtils.spawn('docker', [
                        'build', 
                        workingDir,
                        '-f', dockerFilePath, 
                        '--label', `version=${prepResult.meta.version}`,
                        `--label`, `${imageLabelPrefix}.id=${prepResult.meta.definitionId}`,
                        '--label', `${imageLabelPrefix}.variant=${prepResult.meta.variant}`,
                        '--label', `${imageLabelPrefix}.release=${prepResult.meta.gitRepositoryRelease}`,
                        '--label', `${imageLabelPrefix}.source=${prepResult.meta.gitRepository}`,
                        '--label', `${imageLabelPrefix}.timestamp='${prepResult.meta.buildTimestamp}'`
                    ].concat(buildParams), spawnOpts);

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
    if (definition.hasBaseDockerfile && definition.hasDockerfile) {
        await prep.updateStub(definition, params);
        console.log('(*) Updating devcontainer.json...');
        await definition.updateDevcontainerJson(definition.devcontainerJsonString.replace('"base.Dockerfile"', '"Dockerfile"'));
        console.log('(*) Removing base.Dockerfile...');
        await asyncUtils.rimraf(dockerFilePath);
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

async function isDefinitionVersionAlreadyPublished(definition: Definition, params: CommonParams, variant) {
    // See if image already exists
    const tagsToCheck = definition.getTagList(params.release, false, params.registry, params.repository, variant);
    const tagParts = tagsToCheck[0].split(':');
    const registryName = params.registry.replace(/\..*/, '');
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
