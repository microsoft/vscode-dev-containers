/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as path from 'path';
import { push } from './push';
import { loadConfig, getStagingFolder, getVersionForRelease } from '../utils/config';
import * as asyncUtils from '../utils/async';
import { updateConfigForRelease } from './prep';
import { getAllDefinitions } from '../domain/definition-factory';
import { CommonParams } from '../domain/common';
const packageJson = require('../../../package.json');

export async function packageDefinitions(params: CommonParams, updateLatest: boolean, prepAndPackageOnly: boolean = false, packageOnly: boolean = false, cleanWhenDone: boolean = true, definitionsToSkipPush: string[] = []) {

    // Stage content and load config
    const stagingFolder = await getStagingFolder(params.release);
    await loadConfig(stagingFolder);

    if (!packageOnly) {
        // First, push images, update content
        await push(params, updateLatest, true, prepAndPackageOnly, definitionsToSkipPush);
    }

    // Then package
    console.log(`\n(*) **** Package ${params.release} ****`);

    console.log(`(*) Updating package.json with release version...`);
    const version = getVersionForRelease(params.release);
    const packageJsonVersion = version === 'dev' ? packageJson.version + '-dev' : version;
    const packageJsonPath = path.join(stagingFolder, 'package.json');
    const packageJsonRaw = await asyncUtils.readFile(packageJsonPath);
    const packageJsonModified = packageJsonRaw.replace(/"version".?:.?".+"/, `"version": "${packageJsonVersion}"`);
    await asyncUtils.writeFile(packageJsonPath, packageJsonModified);

    // Update all definition config files for release (devcontainer.json, Dockerfile, library-scripts)
    const allDefinitions = getAllDefinitions();
    for (let currentDefinitionId in allDefinitions) {
        await updateConfigForRelease(allDefinitions[currentDefinitionId], params);
    }

    console.log('(*) Packaging...');
    const opts = { stdio: 'inherit', cwd: stagingFolder, shell: true };
    await asyncUtils.spawn('yarn', ['install'], opts);
    await asyncUtils.spawn('npm', ['pack'], opts); // Need to use npm due to https://github.com/yarnpkg/yarn/issues/685

    let outputPath = null;
    console.log('(*) Moving package...');
    outputPath = path.join(__dirname, '..', '..', `${packageJson.name}-${packageJsonVersion}.tgz`);
    await asyncUtils.copyFile(path.join(stagingFolder, `${packageJson.name}-${packageJsonVersion}.tgz`), outputPath);

    if (cleanWhenDone) {
        // And finally clean up
        console.log('(*) Cleaning up...');
        await asyncUtils.rimraf(stagingFolder);
    }

    console.log('(*) Done!!');

    return outputPath;
}
