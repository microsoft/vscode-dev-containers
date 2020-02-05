/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

const path = require('path');
const push = require('./push').push;
const prep = require('./prep');
const asyncUtils = require('./utils/async');
const configUtils = require('./utils/config');
const packageJson = require('../../package.json');

async function package(repo, release, updateLatest, registry, registryPath, 
    stubRegistry, stubRegistryPath, prepAndPackageOnly, packageOnly, cleanWhenDone) {

    // Optional argument defaults
    packageOnly = typeof packageOnly === 'undefined' ? false : packageOnly;
    prepAndPackageOnly = typeof prepAndPackageOnly === 'undefined' ? false : prepAndPackageOnly;
    cleanWhenDone = typeof cleanWhenDone === 'undefined' ? true : cleanWhenDone;
    stubRegistry = stubRegistry || registry;
    stubRegistryPath = stubRegistryPath || registryPath;

    // Load config files
    await configUtils.loadConfig();

    // Stage content
    const stagingFolder = await configUtils.getStagingFolder(release);
    const definitionStagingFolder = path.join(stagingFolder, 'containers');

    if (!packageOnly) {
        // First, push images, update content
        await push(repo, release, updateLatest, registry, registryPath, stubRegistry, stubRegistryPath, true, prepAndPackageOnly);
    }

    // Then package
    console.log(`\n(*) **** Package ${release} ****`);

    console.log(`(*) Updating package.json with release version...`);
    const version = configUtils.getVersionFromRelease(release);
    const packageJsonVersion = version === 'dev' ? packageJson.version + '-dev' : version;
    const packageJsonPath = path.join(stagingFolder, 'package.json');
    const packageJsonRaw = await asyncUtils.readFile(packageJsonPath);
    const packageJsonModified = packageJsonRaw.replace(/"version".?:.?".+"/, `"version": "${packageJsonVersion}"`);
    await asyncUtils.writeFile(packageJsonPath, packageJsonModified);

    // Update all definition config files for release (devcontainer.json, Dockerfile)
    const allDefinitions = await asyncUtils.readdir(definitionStagingFolder);
    await asyncUtils.forEach(allDefinitions, async (currentDefinitionId) => {
        await prep.updateConfigForRelease(
            path.join(definitionStagingFolder, currentDefinitionId),
            currentDefinitionId, repo, release, registry, registryPath, stubRegistry, stubRegistryPath);
    });

    console.log('(*) Packaging...');
    const opts = { stdio: 'inherit', cwd: stagingFolder, shell: true };
    await asyncUtils.spawn('yarn', ['install'], opts);
    await asyncUtils.spawn('npm', ['pack'], opts); // Need to use npm due to https://github.com/yarnpkg/yarn/issues/685

    let outputPath = null;
    console.log('(*) Moving package...');
    outputPath = path.join(__dirname, '..', '..', `${packageJson.name}-${packageJsonVersion}.tgz`);
    await asyncUtils.rename(path.join(stagingFolder, `${packageJson.name}-${packageJsonVersion}.tgz`), outputPath);

    if (cleanWhenDone) {
        // And finally clean up
        console.log('(*) Cleaning up...');
        await asyncUtils.rimraf(stagingFolder);
    }

    console.log('(*) Done!!');

    return outputPath;
}

module.exports = {
    package: package
}