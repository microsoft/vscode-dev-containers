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

    console.log(`(*) Applying patch located at "${patchPath}"...`);
    const dockerFilePath = `${patchPath}/${dockerFile || 'Dockerfile'}`;
    if (patchConfig.tagList) {
        throw new Error('tagList property has been deprecated.')
    }

    // Update each listed imageId
    asyncUtils.forEach(patchConfig.imageIds, async (imageId) => {
        await patchImage(imageId, dockerFilePath, patchConfig.bumpVersion, registry, registryPath);
    });
    
    // If config says to delete any untagged images mentioned in the patch, do so.
    if (patchConfig.deleteUntaggedImages && patchConfig.imageIds) {
        await deleteUntaggedImages(patchConfig.imageIds, registry);
    }

    console.log('\n(*) Done!')
}

async function patchImage(imageId, dockerFile, bumpVersion, registry) {
    let nameAndTagList = await getImageNameAndTags(registryName, imageId);
    if(nameAndTagList.length<0) {
        console.log('(*) No tags to patch. Skipping.');
        return;
    }

    console.log(`(*) Tags to patch: ${JSON.stringify(tagList, undefined, 4)}`);
    if(bumpVersion) {
        nameAndTagList = updateVersionTags(nameAndTagList);
    }
    //Generate tag arguments
    const tagArgs = nameAndTag.reduce((prev, nameAndTag) => {
        return prev.concat(['--tag', `${registry}/${nameAndTag.name}:${nameAndTag.tag}`])
    }, []);
    // Pull and build patched image for tag
    let retry = false;
    do {
        try {
            const spawnOpts = { stdio: 'inherit', cwd: patchPath, shell: true };
            await asyncUtils.spawn('docker', [ 
                'build',
                '--pull',
                '--build-arg',
                `ORIGINAL_IMAGE=${registry}/${nameAndTagList[0].name}@${imageId}`]
                .concat(tagArgs)
                .concat('-f', dockerFile, patchPath), spawnOpts);
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
}

function updateVersionTags(nameAndTagList) {
    return nameAndTagList.reduce((prev, nameAndTag) => {
        let tag = nameAndTag.tag;
        // Get the version number section of the tag if it exists
        const firstDash = tag.indexOf('-');
        if (firstDash > 0) {
            const versionSection = tag.substring(0, firstDash - 1);
            // See if there are three digits in the version number
            const versionParts = versionSection.split('.');
            if (versionParts.length === 3) {
                // If there are, update the break fix version
                tag = `${versionParts[0]}.${versionParts[1]}.${versionParts[2] + 1}${tag.substring(firstDash)}`;
            }
        }
        return prev.push({
            name: nameAndTag.name,
            tag: tag
        });
    }, []);
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

async function getImageNameAndTags(imageId, registry) {
    // ACR registry name is the registry minus .azurecr.io
    const registryName = registry.replace(/\..*/, '');

    // Get list of repositories
    console.log(`(*) Getting repository list for ACR "${registryName}"...`)
    const repositoryListOutput = await asyncUtils.spawn('az',
        ['acr', 'repository', 'list', '--name', registryName],
        { shell: true, stdio: 'pipe' });
    const repositoryList = JSON.parse(repositoryListOutput);

    let nameAndTagList = [];
    await asyncUtils.forEach(repositoryList, async (repository) => {
        console.log(`(*) Checking in for "${imageId}" in "${repository}"...`);
        const tagListOutput = await asyncUtils.spawn('az',
            ['acr', 'repository', 'show-tags', '--name', registryName, '--repository', repository, "--query", `"[?digest=='${imageId}'].name"`],
            { shell: true, stdio: 'pipe' });
        const additionalTags = JSON.parse(tagListOutput);
        nameAndTagList = nameAndTagList.concat(additionalTags.map((tag) => {
            return { 
                repository:repository,
                tag:tag
            };
        }));
    });
    return nameAndTagList;
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