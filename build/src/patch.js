/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

const path = require('path');
const asyncUtils = require('./utils/async');
const jsonc = require('jsonc').jsonc;

async function patch(patchPath, registry, registryPath) {
    patchPath = path.resolve(patchPath);
    const patchConfig = await getPatchConfig(patchPath);
    // ACR registry name is the registry minus .azurecr.io
    const registryName = registry.replace(/\..*/, '');

    console.log(`(*) Applying patch located at "${patchPath}"...`);
    let tagList = patchConfig.tagList || [];
    // If imageIds specified, get the complete list of tags to update
    if (patchConfig.imageIds) {
        const manifests = await getImageManifests(registryName, patchConfig.imageIds);
        tagList = tagList.concat(manifests.reduce((prev, manifest) => {
            return prev.concat(manifest.tags.map((tag) => {
                return `${manifest.repository}:${tag}`;
            }));
        }, []));
    }
    console.log(`(*) Tags to patch: ${JSON.stringify(tagList, undefined, 4)}`);

    const spawnOpts = { stdio: 'inherit', cwd: patchPath, shell: true };
    await asyncUtils.forEach(tagList, async (tag) => {
        const newTag = patchConfig.bumpVersion ? updateVersionTag(tag, registryPath) : tag;
        console.log(`\n(*) Patching ${tag}...`);

        // Pull and build patched image for tag
        let retry = false;
        do {
            try {
                await asyncUtils.spawn('docker', [
                    'build',
                    '--pull',
                    '--build-arg', `ORIGINAL_IMAGE=${registry}/${tag}`,
                    '--tag', `${registry}/${newTag}`,
                    '-f', `${patchPath}/${patchConfig.dockerFile || 'Dockerfile'}`,
                    patchPath
                ], spawnOpts);
                done = true;
            } catch (ex) {
                // Try to clean out unused images and retry once if get an out of storage response
                if (ex.result.indexOf('no space left on device') >= 0 && retry === false) {
                    console.log(`(*) Out of space - pruning images..`);
                    asyncUtils.spawn('docker', ['image', 'prune', '--all', '--force'], spawnOpts);
                    console.log(`(*) Retrying..`);
                    retry = true;
                } else {
                    throw ex;
                }
            }    
        } while (retry);

        // Push update
        await asyncUtils.spawn('docker', ['push', `${registry}/${newTag}`], spawnOpts);
    });

    // If config says to delete any untagged images mentioned in the patch, do so.
    if (patchConfig.deleteUntaggedImages && patchConfig.imageIds) {
        await deleteUntaggedImages(patchConfig.imageIds, registry);
    }

    console.log('\n(*) Done!')
}

function updateVersionTag(fullTag, registryPath) {
    const tag = fullTag.replace(registryPath + '/', '');
    // Get the version number section of the tag if it exists
    const colon = tag.indexOf(':');
    const firstDash = tag.indexOf('-', colon);
    if (firstDash > 0) {
        const versionSection = tag.substring(colon + 1, firstDash - 1);
        // See if there are three digits in the version number
        const versionParts = versionSection.split('.');
        if (versionParts.length === 3) {
            // If there are, update the break fix version
            return `${tag.substring(0, colon + 1)}${versionParts[0]}.${versionParts[1]}.${versionParts[2] + 1}${tag.substring(firstDash)}`;
        }
        return `${registryPath}:${tag}`;
    }
    return tag;
}

async function deleteUnpatchedImages(patchPath, registry) {
    patchPath = path.resolve(patchPath);
    const patchConfig = await getPatchConfig(patchPath);
    if (!patchConfig.imageIds) {
        console.log('(!) Patch does not include image IDs.  Nothing to do.');
        return;
    }
    return await deleteUntaggedImages(patchConfig.imageIds, registry);
}

async function deleteUntaggedImages(imageIds, registry) {

    console.log(`(*) Deleting untagged images...`);
    // ACR registry name is the registry minus .azurecr.io
    const registryName = registry.replace(/\..*/, '');

    const manifests = await getImageManifests(registryName, imageIds);

    console.log(`(*) Manifests to delete: ${JSON.stringify(manifests, undefined, 4)}`);

    const spawnOpts = { stdio: 'inherit', shell: true };
    await asyncUtils.forEach(manifests, async (manifest) => {
        if (manifest.tags.length > 0) {
            console.log(`(!) Skipping ${manifest.digest} because it has tags: ${manifest.tags}`);
            return;
        }
        const fullImageId = `${manifest.repository}@${manifest.digest}`;
        console.log(`(*) Deleting ${fullImageId}...`);
        // Pull and build patched tag
        await asyncUtils.spawn('az', [
            'acr',
            'repository',
            'delete',
            '--yes',
            '--name', registryName,
            '--image', fullImageId
        ], spawnOpts);
    });

    console.log('\n(*) Done deleting manifests!')
}

async function getImageManifests(registryName, imageIds) {
    let manifests = [];

    // Get list of repositories
    console.log(`(*) Getting repository list for ACR "${registryName}"...`)
    const repositoryListOutput = await asyncUtils.spawn('az',
        ['acr', 'repository', 'list', '--name', registryName],
        { shell: true, stdio: 'pipe' });
    const repositoryList = JSON.parse(repositoryListOutput);

    // Query each repository for images, then add any tags found to the list
    const query = imageIds.reduce((prev, current) => {
        return prev ? `${prev} || digest=='${current}'` : `"[?digest=='${current}'`;
    }, null) + '] | []"';
    await asyncUtils.forEach(repositoryList, async (repository) => {
        console.log(`(*) Getting manifests from "${repository}"...`);
        const registryManifestListOutput = await asyncUtils.spawn('az',
            ['acr', 'repository', 'show-manifests', '--name', registryName, '--repository', repository, "--query", query],
            { shell: true, stdio: 'pipe' });
        let registryManifestList = JSON.parse(registryManifestListOutput);
        registryManifestList = registryManifestList.map((manifest) => {
            manifest.repository = repository;
            return manifest;
        });
        manifests = manifests.concat(registryManifestList);
    });

    return manifests;
}

async function getPatchConfig(patchPath) {
    const patchConfigFilePath = path.resolve(patchPath, 'patch.json');
    if (!await asyncUtils.exists(patchConfigFilePath)) {
        throw (`No patch.json found at ${patchConfigFilePath}`);
    }
    const patchConfig = await jsonc.read(patchConfigFilePath);

    if (typeof patchConfig.bumpVersion === 'undefined') {
        patchConfig.bumpVersion = true;
    }
    if (typeof patchConfig.deleteUntaggedImages === 'undefined') {
        patchConfig.deleteUntaggedImages = false;
    }

    return patchConfig;

}

async function patchAll(registry, registryPath) {
    const patchRoot = path.resolve(__dirname, '..', 'patch');
    const patchStatusFilePath = path.join(patchRoot, 'status.json');
    const patchStatus = await asyncUtils.exists(patchStatusFilePath) ? await jsonc.read(patchStatusFilePath) : { complete: {}, failed: {} }
    patchStatus.failed = {};
    const patchList = await asyncUtils.readdir(patchRoot, { withFileTypes: true });
    await asyncUtils.forEach(patchList, async (patchEntry) => {
        if (patchStatus.complete[patchEntry.name]) {
            console.log(`(*) Patch ${patchEntry.name} already complete.`);
            return;
        }
        if (patchEntry.isDirectory()) {
            try {
                await patch(path.join(patchRoot, patchEntry.name), registry, registryPath);
                patchStatus.complete[patchEntry.name] = true;
            } catch (ex) {
                console.log(`(!) Patch ${patchEntry.name} failed - ${ex}.`);
                patchStatus.failed[patchEntry.name] = JSON.stringify(ex, undefined, 4);
                await asyncUtils.writeFile(patchStatusFilePath, JSON.stringify(patchStatus, undefined, 4))
                throw ex;
            }
        }
    });

    // Write status file for next time
    await asyncUtils.writeFile(patchStatusFilePath, JSON.stringify(patchStatus, undefined, 4))
}

module.exports = {
    patchAll: patchAll,
    patch: patch,
    deleteUnpatchedImages: deleteUnpatchedImages
}