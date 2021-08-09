/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as path from 'path';
import * as asyncUtils from './utils/async';
import { jsonc } from 'jsonc';
import { CommonParams } from './domain/common';

interface RepoAndTag { 
    repository: string; 
    tag:
}

export async function patch(params: CommonParams, patchPath: string) {
    patchPath = path.resolve(patchPath);
    const patchConfig = await getPatchConfig(patchPath);

    console.log(`(*) Applying patch located at "${patchPath}"...`);
    const dockerFilePath = `${patchPath}/${patchConfig.dockerFile || 'Dockerfile'}`;
    if (patchConfig.tagList) {
        throw new Error('tagList property has been deprecated.')
    }

    // Update each listed imageId
    await asyncUtils.forEach(patchConfig.imageIds, async (imageId) => {
        await patchImage(params, imageId, patchPath, dockerFilePath, patchConfig.bumpVersion);
    });

    // If config says to delete any untagged images mentioned in the patch, do so.
    if (patchConfig.deleteUntaggedImages && patchConfig.imageIds) {
        await deleteUntaggedImages(params, patchConfig.imageIds);
    }
    
    console.log('\n(*) Done!')
}

async function patchImage(params:CommonParams, imageId, patchPath, dockerFilePath, bumpVersion) {
    console.log(`\n*** Updating Image: ${imageId} ***`);
    const spawnOpts = { stdio: 'inherit', cwd: patchPath, shell: true };

    // Get repository and tag list for imageId
    let repoAndTagList = await getImageRepositoryAndTags(params, imageId);
    if(repoAndTagList.length === 0) {
        console.log('(*) No tags to patch. Skipping.');
        return;
    }

    console.log(`(*) Tags to update: ${
            JSON.stringify(repoAndTagList.reduce((prev, repoAndTag) => { return prev + repoAndTag.repository + ':' + repoAndTag.tag + ' ' }, ''), undefined, 4)
        }`);

    // Bump breakfix number of it applies
    if(bumpVersion) {
        repoAndTagList = updateVersionTags(repoAndTagList);
    }

    //Generate tag arguments
    const tagArgs = repoAndTagList.reduce((prev, repoAndTag) => {
        return prev.concat(['--tag', `${params.registry}/${repoAndTag.repository}:${repoAndTag.tag}`])
    }, []);

    // Pull and build patched image for tag
    let retry = false;
    do {
        try {
            await asyncUtils.spawn('docker', [ 
                'build',
                '--pull',
                '--build-arg',
                `ORIGINAL_IMAGE=${params.registry}/${repoAndTagList[0].repository}@${imageId}`]
                .concat(tagArgs)
                .concat('-f', dockerFilePath, patchPath), spawnOpts);
        } catch (ex) {
            // Try to clean out unused images and retry once if get an out of storage response
            if (ex.result && ex.result.indexOf('no space left on device') >= 0 && retry === false) {
                console.log(`(*) Out of space - pruning all unused images...`);
                await asyncUtils.spawn('docker', ['image', 'prune', '--all', '--force'], spawnOpts);
                console.log(`(*) Retrying...`);
                retry = true;
            } else {
                throw ex;
            }
        }    
    } while (retry);

    // Push updates
    await asyncUtils.forEach(repoAndTagList, async (repoAndTag) => {
        await asyncUtils.spawn('docker', ['push', `${params.registry}/${repoAndTag.repository}:${repoAndTag.tag}`], spawnOpts);
    });

    // Prune proactively to reduce space use
    console.log(`(*) Pruning dangling images...`);
    await asyncUtils.spawn('docker', ['image', 'prune', '--force'], spawnOpts);
}

function updateVersionTags(repoAndTagList: RepoAndTag[]) {
    return repoAndTagList.reduce((prev: RepoAndTag[], repoAndTag: RepoAndTag) => {
        let tag = repoAndTag.tag;
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
            repository: repoAndTag.repository,
            tag: tag
        } as RepoAndTag);
    }, []);
}

export  async function deleteUnpatchedImages(params:CommonParams, patchPath: string) {
    patchPath = path.resolve(patchPath);
    const patchConfig = await getPatchConfig(patchPath);
    if (!patchConfig.imageIds) {
        console.log('(!) Patch does not include image IDs.  Nothing to do.');
        return;
    }
    return await deleteUntaggedImages(params, patchConfig.imageIds);
}

async function deleteUntaggedImages(params:CommonParams, imageIds: string[]) {

    console.log('\n*** Deleting untagged images ***');
    // ACR registry name is the registry minus .azurecr.io
    const registryName = params.registry.replace(/\..*/, '');

    const manifests = await getImageManifests(params, imageIds);

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

    console.log('(*) Done deleting manifests!')
}

// Find tags for image
async function getImageRepositoryAndTags(params: CommonParams, imageId: string): Promise<RepoAndTag[]> {
    // ACR registry name is the registry minus .azurecr.io
    const registryName = params.registry.replace(/\..*/, '');

    // Get list of repositories
    console.log(`(*) Getting repository list for ACR "${registryName}"...`)
    const repositoryListOutput = await asyncUtils.spawn('az',
        ['acr', 'repository', 'list', '--name', registryName],
        { shell: true, stdio: 'pipe' });
    const repositoryList = JSON.parse(repositoryListOutput);

    let repoAndTagList = [];
    await asyncUtils.forEach(repositoryList, async (repository: string) => {
        console.log(`(*) Checking in for "${imageId}" in "${repository}"...`);
        const tagListOutput = await asyncUtils.spawn('az',
            ['acr', 'repository', 'show-tags', '--detail', '--name', registryName, '--repository', repository, "--query", `"[?digest=='${imageId}'].name"`],
            { shell: true, stdio: 'pipe' });
        const additionalTags = JSON.parse(tagListOutput);
        repoAndTagList = repoAndTagList.concat(additionalTags.map((tag: string) => {
            return { 
                repository:repository,
                tag:tag
            } as RepoAndTag;
        }));
    });
    return repoAndTagList;
}

async function getImageManifests(params:CommonParams, imageIds: string[]) {
    // ACR registry name is the registry minus .azurecr.io
    const registryName = params.registry.replace(/\..*/, '');

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

async function getPatchConfig(patchPath: string) {
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

export async function patchAll(params: CommonParams) {
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
                await patch(params, path.join(patchRoot, patchEntry.name));
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
