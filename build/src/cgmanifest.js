const path = require('path');
const push = require('./push').push;
const asyncUtils = require('./utils/async');
const configUtils = require('./utils/config');

// Example manifest: https://dev.azure.com/mseng/AzureDevOps/_git/Governance.Specs?path=%2Fcgmanifest.json&version=GBusers%2Fcajone%2Fcgmanifest.json
// Docker images and native OS libraries need to be registered as "other" while others are scenario dependant

const dependencyLookupConfig = {
    debian: {
        // Command to get package versions: dpkg-query --show -f='${Package}\t${Version}\n' <package>
        // Output: <package>    <version>
        // Command to get download URLs: apt-get update && apt-get install -y --reinstall --print-uris
        namePrefix: 'Debian Package:',
        listCommand: "dpkg-query --show -f='${Package}\t${Version}\n'",
        lineRegEx: /(.+)\t(.+)/,
        getUriCommand: 'apt-get update && apt-get install -y --reinstall --print-uris',
        uriMatchRegex: "'(.+)'\\s*${PACKAGE}_${VERSION}"
    },
    ubuntu: {
        // Command to get package versions: dpkg-query --show -f='${Package}\t${Version}\n' <package>
        // Output: <package>    <version>
        // Command to get download URLs: apt-get update && apt-get install -y --reinstall --print-uris
        namePrefix: 'Ubuntu Package:',
        listCommand: "dpkg-query --show -f='${Package}\t${Version}\n'",
        lineRegEx: /(.+)\t(.+)/,
        getUriCommand: 'apt-get update && apt-get install -y --reinstall --print-uris',
        uriMatchRegex: "'(.+)'\\s*${PACKAGE}_${VERSION}"
    },
    alpine: {
        // Command to get package versions: apk info -e -v <package>
        // Output: <package-with-maybe-dashes>-<version-with-dashes>
        // Command to get download URLs: apk policy
        namePrefix: 'Alpine Package:',
        listCommand: "apk info -e -v",
        lineRegEx: /(.+)-([0-9].+)/,
        getUriCommand: 'apk update && apk policy',
        uriMatchRegex: '${PACKAGE} policy:\\n.*${VERSION}:\\n.*lib/apk/db/installed\\n\\s*(.+)\\n',
        uriSuffix: '/x86_64/${PACKAGE}-${VERSION}.apk'
    }
}

async function generateComponentGovernanceManifest(repo, release, registry, registryPath, buildFirst) {
    // Load config files
    await configUtils.loadConfig();

    if (buildFirst) {
        // Simulate the build and push process, but don't actually push 
        console.log('(*) Simulating push process to trigger image builds...');
        await push(repo, release, false, registry, registryPath, registry, registryPath, true);
    } else {
        console.log('(*) Using existing local images...');
    }

    const alreadyRegistered = {};
    const cgManifest = {
        "Registrations": [],
        "Version": 1
    }

    console.log('(*) Generating manifest...');
    const definitionDependencies = configUtils.getAllDependencies();
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
            const imageTag = configUtils.getTagsForVersion(definitionId, 'dev', registry, registryPath)[0]

            // Run commands in the package to pull out needed versions
            cgManifest.Registrations = cgManifest.Registrations.concat(
                await generatePackageComponentList(dependencyLookupConfig.debian, dependencies.debian, imageTag, alreadyRegistered),
                await generatePackageComponentList(dependencyLookupConfig.ubuntu, dependencies.ubuntu, imageTag, alreadyRegistered),
                await generatePackageComponentList(dependencyLookupConfig.alpine, dependencies.alpine, imageTag, alreadyRegistered),
                await generateNpmComponentList(dependencies.npm, alreadyRegistered),
                filteredManualComponentRegistrations(dependencies.manual, alreadyRegistered));
        }
    }
    console.log('(*) Writing manifest...');
    await asyncUtils.writeFile(
        path.join(__dirname, '..', '..', 'cgmanifest.json'),
        JSON.stringify(cgManifest, undefined, 4))
    console.log('(*) Done!');
}

async function generatePackageComponentList(config, packageList, imageTag, alreadyRegistered) {
    if(!packageList) {
        return [];
    }

    const componentList = [];
    console.log(`(*) Generating Linux package registrations for ${imageTag}...`);

    // Generate and exec command to get installed package versions
    console.log('(*) Getting package versions...');
    const packageVersionListCommand = packageList.reduce((prev, current) => {
        return prev += ` ${current}`;
    }, config.listCommand);
    const packageVersionListOutput = await asyncUtils.spawn('docker',
        ['run', '--rm', imageTag, packageVersionListCommand],
        { shell: true, stdio: 'pipe' });

    // Generate and exec command to extract download URIs
    console.log('(*) Getting package download URLs...');
    const packageUriCommand = packageList.reduce((prev, current) => {
        return prev += ` ${current}`;
    }, config.getUriCommand);
    const packageUriCommandOutput = await asyncUtils.spawn('docker',
        ['run', '--rm', imageTag, `sh -c '${packageUriCommand}'`],
        { shell: true, stdio: 'pipe' });

    const packageVersionList = packageVersionListOutput.split('\n');
    packageVersionList.forEach((packageVersion) => {
        packageVersion = packageVersion.trim();
        if (packageVersion !== '') {
            const versionCaptureGroup = new RegExp(config.lineRegEx).exec(packageVersion);
            const package = versionCaptureGroup[1];
            const version = versionCaptureGroup[2];

            const entry = createEntryForLinuxPackage(packageUriCommandOutput, config.namePrefix, package, version, alreadyRegistered, config.uriMatchRegex, config.uriSuffix)
            if (entry) {
                componentList.push(entry);
            }
        }
    });

    return componentList;
}

function createEntryForLinuxPackage(packageUriCommandOutput, entryNamePrefix, package, version, alreadyRegistered, uriMatchRegex, uriSuffix)
{
    const uniquePackageName = `${entryNamePrefix} ${package}`;
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

        alreadyRegistered[uniquePackageName] = alreadyRegistered[uniquePackageName] || [];
        alreadyRegistered[uniquePackageName].push(version);

        return {
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
        }
    }

    return null;
}

function filteredManualComponentRegistrations(manualRegistrations, alreadyRegistered) {
    if(!manualRegistrations) {
        return [];
    }
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
    if(!packageList) {
        return [];
    }

    console.log(`(*) Generating npm registrations...`);

    const componentList = [];
    await asyncUtils.forEach(packageList, async (package) => {
        let version = '';
        if (package.indexOf('@') >= 0) {
            [package, version] = package.split('@');
        } else {
            const npmInfoRaw = await asyncUtils.spawn('npm', ['info', package, '--json'], { shell: true, stdio: 'pipe' });
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
    });
    return componentList;
}

module.exports = {
    generateComponentGovernanceManifest: generateComponentGovernanceManifest
}
