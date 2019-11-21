const path = require('path');
const push = require('./push').push;
const utils = require('./utils');
const definitionDependencies = require('../definition-dependencies.json');

// Example manifest: https://dev.azure.com/mseng/AzureDevOps/_git/Governance.Specs?path=%2Fcgmanifest.json&version=GBusers%2Fcajone%2Fcgmanifest.json
// Docker images and native OS libraries need to be registered as "other" while others are scenario dependant

module.exports = {
    generateComponentGovernanceManifest: async (repo, release, registry, registryPath) => {
        console.log('(*) Simulating push process to trigger image builds...');

        // Simulate the build and push process, but don't actually push 
        await push(repo, release, false, registry, registryPath, registry, registryPath, true);

        const alreadyRegistered = {};
        const cgManifest = {
            "Registrations": [],
            "Version": 1
        }

        console.log('(*) Generating manifest...');
        for (let definitionId in definitionDependencies) {
            const dependencies = definitionDependencies[definitionId];
            if (typeof dependencies === 'object') {

                // Add Docker image registration
                const [image, imageVersion] = dependencies.image.split(':');
                if (typeof alreadyRegistered[dependencies.image] === 'undefined') {
                    cgManifest.Registrations.push({
                        "Component": {
                            "Type": "other",
                            "Other": {
                                "Name": `Docker Image: ${image}`,
                                "Version": imageVersion,
                                "DownloadUrl": dependencies.imageLink
                            }
                        }
                    });
                    alreadyRegistered[dependencies.image] = [imageVersion];
                }

                // Docker image to use to determine installed package versions
                const imageTag = utils.getTagsForVersion(definitionId, 'dev', registry, registryPath)[0]

                // Run commands in the package to pull out needed versions - Debian
                if (dependencies.debian) {
                    // Command to get package versions: dpkg-query --show -f='${Package}\t${Version}\n' <package>
                    // Output: <package>    <version>
                    // Command to get download URLs: apt-get update && apt-get install -y --reinstall --print-uris
                    console.log(`(*) Generating Debian package registrations for ${imageTag}...`);
                    cgManifest.Registrations = cgManifest.Registrations.concat(await generatePackageComponentList(
                        'Debian Package:',
                        dependencies.debian,
                        imageTag,
                        alreadyRegistered,
                        "dpkg-query --show -f='${Package}\t${Version}\n'",
                        /(.+)\t(.+)/,
                        'apt-get update && apt-get install -y --reinstall --print-uris',
                        "'(.+)'\\s*${PACKAGE}_${VERSION}"));
                }

                // Run commands in the package to pull out needed versions - Ubuntu
                if (dependencies.ubuntu) {
                    // Command to get package versions: dpkg-query --show -f='${Package}\t${Version}\n' <package>
                    // Output: <package>    <version>
                    // Command to get download URLs: apt-get update && apt-get install -y --reinstall --print-uris
                    console.log(`(*) Generating Ubuntu package registrations for ${imageTag}...`);
                    cgManifest.Registrations = cgManifest.Registrations.concat(await generatePackageComponentList(
                        'Ubuntu Package:',
                        dependencies.ubuntu,
                        imageTag,
                        alreadyRegistered,
                        "dpkg-query --show -f='${Package}\t${Version}\n'",
                        /(.+)\t(.+)/,
                        'apt-get update && apt-get install -y --reinstall --print-uris',
                        "'(.+)'\\s*${PACKAGE}_${VERSION}"));
                }

                // Run commands in the package to pull out needed versions - Alpine
                if (dependencies.alpine) {
                    // Command to get package versions: apk info -e -v <package>
                    // Output: <package-with-maybe-dashes>-<version-with-dashes>
                    // Command to get download URLs: apk policy
                    console.log(`(*) Generating Alpine package registrations for ${imageTag}...`);
                    cgManifest.Registrations = cgManifest.Registrations.concat(await generatePackageComponentList(
                        'Alpine Package:',
                        dependencies.alpine,
                        imageTag,
                        alreadyRegistered,
                        "apk info -e -v",
                        /(.+)-([0-9].+)/,
                        'apk update && apk policy',
                        '${PACKAGE} policy:\\n.*${VERSION}:\\n.*lib/apk/db/installed\\n\\s*(.+)\\n',
                        '/x86_64/${PACKAGE}-${VERSION}.apk'));

                }
            }

            if (dependencies.npm) {
                console.log(`(*) Generating npm registrations for ${definitionId}...`);
                cgManifest.Registrations = cgManifest.Registrations.concat(
                    await generateNpmComponentList(dependencies.npm, alreadyRegistered));
            }

            // Add manual registrations
            if (dependencies.manual) {
                cgManifest.Registrations = cgManifest.Registrations.concat(
                    filteredManualComponentRegistrations(dependencies.manual, alreadyRegistered));
            }

        }
        console.log('(*) Writing manifest...');
        await utils.writeFile(
            path.join(__dirname, '..', '..', 'cgmanifest.json'),
            JSON.stringify(cgManifest, undefined, 4))
        console.log('(*) Done!');
    }
}

async function generatePackageComponentList(namePrefix, packageList, imageTag, alreadyRegistered, listCommand, lineRegEx, getUriCommand, uriMatchRegex, uriSuffix) {
    const componentList = [];

    // Generate and exec command to get installed package versions
    console.log('(*) Getting package versions...');
    const packageVersionListCommand = packageList.reduce((prev, current) => {
        return prev += ` ${current}`;
    }, listCommand);
    const packageVersionListOutput = await utils.spawn('docker',
        ['run', '--rm', imageTag, packageVersionListCommand],
        { shell: true, stdio: 'pipe' });

    // Generate and exec command to extract download URIs
    console.log('(*) Getting package download URLs...');
    const packageUriCommand = packageList.reduce((prev, current) => {
        return prev += ` ${current}`;
    }, getUriCommand);
    const packageUriCommandOutput = await utils.spawn('docker',
        ['run', '--rm', imageTag, `sh -c '${packageUriCommand}'`],
        { shell: true, stdio: 'pipe' });

    const packageVersionList = packageVersionListOutput.split('\n');
    packageVersionList.forEach((packageVersion) => {
        packageVersion = packageVersion.trim();
        if (packageVersion !== '') {
            const versionCaptureGroup = new RegExp(lineRegEx).exec(packageVersion);
            const package = versionCaptureGroup[1];
            const version = versionCaptureGroup[2];
            const uniquePackageName = `${namePrefix} ${package}`;
            if (typeof alreadyRegistered[uniquePackageName] === 'undefined'
                || alreadyRegistered[uniquePackageName].indexOf(version) < 0) {

                // Handle regex reserved charters in regex strings and that ":" is treaded as "1%3a" on Debian/Ubuntu 
                const sanitizedPackage = package.replace(/\+/g, '\\+').replace(/\./g, '\\.');
                const sanitizedVersion = version.replace(/\+/g, '\\+').replace(/\./g, '\\.').replace(/:/g, '%3a');
                const uriCaptureGroup = new RegExp(
                    uriMatchRegex.replace('${PACKAGE}', sanitizedPackage).replace('${VERSION}', sanitizedVersion), 'm')
                    .exec(packageUriCommandOutput);

                if (!uriCaptureGroup) {
                    console.log(`(!) No URI found for ${package} ${version}`)
                }

                const uriString = uriCaptureGroup ? uriCaptureGroup[1] : '';

                componentList.push({
                    "Component": {
                        "Type": "other",
                        "Other": {
                            "Name": uniquePackageName,
                            "Version": version,
                            "DownloadUrl": `${uriString}${uriSuffix ?
                                uriSuffix.replace('${PACKAGE}', package).replace('${VERSION}', version)
                                : ''}`
                        }
                    }
                });
                alreadyRegistered[uniquePackageName] = alreadyRegistered[uniquePackageName] || [];
                alreadyRegistered[uniquePackageName].push(version);
            }
        }
    });

    return componentList;
}

function filteredManualComponentRegistrations(manualRegistrations, alreadyRegistered) {
    const componentList = [];
    manualRegistrations.forEach((component) => {
        const key = JSON.stringify(component);
        if (typeof alreadyRegistered[key] === 'undefined') {
            componentList.push(component);
            alreadyRegistered[key] = [key];
        }
    });
    return componentList;
}

async function generateNpmComponentList(packageList, alreadyRegistered) {
    const componentList = [];
    for (let i = 0; i < packageList.length; i++) {
        let package = packageList[i];
        let version = '';
        if (package.indexOf('@') >= 0) {
            [package, version] = package.split('@');
        } else {
            const npmInfoRaw = await utils.spawn('npm', ['info', package, '--json'], { shell: true, stdio: 'pipe' });
            const npmInfo = JSON.parse(npmInfoRaw);
            version = npmInfo['dist-tags'].latest;
        }
        const uniquePackageName = `npm-${package}`;
        if (typeof alreadyRegistered[uniquePackageName] === 'undefined'
            || alreadyRegistered[uniquePackageName].indexOf(version) < 0) {
            componentList.push({
                "Component": {
                    "Type": "npm",
                    "Npm": {
                        "Name": package,
                        "Version": version
                    }
                }
            });
            alreadyRegistered[uniquePackageName] = alreadyRegistered[uniquePackageName] || [];
            alreadyRegistered[uniquePackageName].push(version);
        }
    }
    return componentList;
}