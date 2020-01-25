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

    const spawnOpts = { stdio: 'inherit', cwd: patchPath,  shell: true };
    await asyncUtils.forEach(patchConfig.tagList, async (tag) => {
        const fullTag = `${registry}/${registryPath}/${tag}`;
        const fullNewTag = `${registry}/${registryPath}/${patchConfig.bumpVersion ? updateVersionTag(tag) : tag}`;
        console.log(`\n(*) Patching ${fullTag}...`);

        // Pull and build patched tag
        await asyncUtils.spawn('docker', [
                'build',
                '--pull',
                '--build-arg', `ORIGINAL_IMAGE=${fullTag}`,
                '--tag', fullNewTag,
                '-f', patchConfig.dockerFile || 'Dockerfile',
                patchPath
            ], spawnOpts);

        // Push update
        await asyncUtils.spawn('docker', ['push', fullNewTag], spawnOpts);
    });

    console.log('\n(*) Done!')
}

function updateVersionTag(tag) {
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
        return tag;
    }
    return tag;
}

module.exports = {
    patch: patch
}