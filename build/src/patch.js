/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

const path = require('path');
const asyncUtils = require('./utils/async');

async function patch(patchPath, registry, registryPath) {

    console.log(`(*) Applying patch located at "${patchPath}"...`);
    patchPath = path.resolve(patchPath);
    const patchConfigFilePath = path.resolve(patchPath, 'patch.json');

    const patchConfig = require(patchConfigFilePath);
    if (typeof patchConfig.bumpVersion === 'undefined') {
        patchConfig.bumpVersion = true;
    }

    const tagList = patchConfig.tagList || []
    // If imageIds specified, get the complete list of tags to update

    if (patchConfig.imageIds) {
        // ACR registry name is the registry minus .azurecr.io
        const registryName = registry.replace(/\..*/, '');
        // Get list of repositories
        console.log(`(*) Getting repository list for ACR "${registryName}"...`)
        const repositoryListOutput = await asyncUtils.spawn('az',
            ['acr', 'repository', 'list', '--name', registryName],
            { shell: true, stdio: 'pipe' });
        const repositoryList = JSON.parse(repositoryListOutput);

        // Query each repository for images, then add any tags found to the list
        const query =  patchConfig.imageIds.reduce((prev, current) => {
                    return prev ?  `${prev} || digest=='${current}'` : `"[?digest=='${current}'`;
           }, null) + '].tags | []"';
        await asyncUtils.forEach(repositoryList, async (repository) => {
            console.log(`(*) Searching for tags in "${repository}"...`)
            const registryTagListOutput = await asyncUtils.spawn('az',
                ['acr', 'repository', 'show-manifests', '--name', registryName, '--repository', repository, "--query", query],
                { shell: true, stdio: 'pipe' });
            const registryTagList = JSON.parse(registryTagListOutput);
            registryTagList.forEach((tag) => {
                tagList.push(`${repository}:${tag}`);
            });
        });
    }
    console.log(`(*) Tags to patch: ${JSON.stringify(tagList, 4)}`);

    const spawnOpts = { stdio: 'inherit', cwd: patchPath,  shell: true };
    await asyncUtils.forEach(tagList, async (tag) => {
        const newTag = patchConfig.bumpVersion ? updateVersionTag(tag, registryPath) : tag;
        console.log(`\n(*) Patching ${tag}...`);

        // Pull and build patched tag
        await asyncUtils.spawn('docker', [
                'build',
                '--pull',
                '--build-arg', `ORIGINAL_IMAGE=${registry}/${tag}`,
                '--tag', `${registry}/${newTag}`,
                '-f', `${patchPath}/${patchConfig.dockerFile || 'Dockerfile'}`,
                patchPath
            ], spawnOpts);

        // Push update
        await asyncUtils.spawn('docker', ['push', `${registry}/${newTag}`], spawnOpts);
    });

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

module.exports = {
    patch: patch
}