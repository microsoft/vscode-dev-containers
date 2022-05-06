/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

const asyncUtils = require('./async');
const configUtils = require('./config');

// Docker images and native OS libraries need to be registered as "other" while others are scenario dependant
const linuxPackageInfoExtractionConfig = {
    apt: {
        // Command to get package versions: dpkg-query --show -f='${Package}\t${Version}\n' <package>
        // Output: <package>    <version>
        // Command to get download URLs: apt-get update && apt-get install -y --reinstall --print-uris
        // Output: Multi-line output, but each line is '<download URL>.deb' <package>_<version>_<architecture>.deb <size> <checksum> 
        namePrefix: 'Debian Package:',
        listCommand: "dpkg-query --show -f='\\${Package} ~~v~~ \\${Version}\n'",
        lineRegEx: /(.+) ~~v~~ (.+)/,
        getUriCommand: 'apt-get update && apt-get install -y --reinstall --print-uris',
        downloadUriMatchRegEx: "'(.+\\.deb)'\\s*${PACKAGE}_.+\\s",
        poolUriMatchRegEx: "'(.+)/pool.+\\.deb'\\s*${PACKAGE}_.+\\s"
    },
    apk: {
        // Command to get package versions: apk info -e -v <package>
        // Output: <package-with-maybe-dashes>-<version-with-dashes>
        // Command to get download URLs: apk policy
        namePrefix: 'Alpine Package:',
        listCommand: "apk info -e -v",
        lineRegEx: /(.+)-([0-9].+)/,
        getUriCommand: 'apk update && apk policy',
        downloadUriMatchRegEx: '${PACKAGE} policy:\\n.*${VERSION}:\\n.*lib/apk/db/installed\\n\\s*(.+)\\n',
        downloadUriSuffix: '/x86_64/${PACKAGE}-${VERSION}.apk',
        poolUriMatchRegEx: '${PACKAGE} policy:\\n.*${VERSION}:\\n.*lib/apk/db/installed\\n\\s*(.+)\\n',
    }
}
linuxPackageInfoExtractionConfig.alpine = linuxPackageInfoExtractionConfig.apk;
linuxPackageInfoExtractionConfig.debian = linuxPackageInfoExtractionConfig.apt;
linuxPackageInfoExtractionConfig.ubuntu = linuxPackageInfoExtractionConfig.apt;

/* This function converts the contents of /etc/os-release from this:

    PRETTY_NAME="Debian GNU/Linux 10 (buster)"
    NAME="Debian GNU/Linux"
    VERSION_ID="10"
    VERSION="10 (buster)"
    VERSION_CODENAME=buster
    ID=debian
    HOME_URL="https://www.debian.org/"
    SUPPORT_URL="https://www.debian.org/support"
    BUG_REPORT_URL="https://bugs.debian.org/"

to an object like this:

{
    prettyName: "Debian GNU/Linux 10 (buster)"
    name: "Debian GNU/Linux"
    versioonId: "10"
    version: "10 (buster)"
    versionCodename: buster
    id: debian
    homeUrl: "https://www.debian.org/"
    supportUrl: "https://www.debian.org/support"
    bugReportUrl: "https://bugs.debian.org/"
}
*/
async function getLinuxDistroInfo(imageTagOrContainerName) {
    const info = {};
    const osInfoCommandOutput = await getCommandOutputFromContainer(imageTagOrContainerName, 'cat /etc/os-release', true);
    const osInfoLines = osInfoCommandOutput.split('\n');
    osInfoLines.forEach((infoLine) => {
        const infoLineParts = infoLine.split('=');
        if (infoLineParts.length === 2) {
            const propName = snakeCaseToCamelCase(infoLineParts[0].trim());
            info[propName] = infoLineParts[1].replace(/"/g,'').trim();    
        }
    })
    return info;
}

// Convert SNAKE_CASE to snakeCase ... well, technically camelCase :)
function snakeCaseToCamelCase(variableName) {
    return variableName.split('').reduce((prev, next) => {
        if(prev.charAt(prev.length-1) === '_') {
            return prev.substr(0, prev.length-1) + next.toLocaleUpperCase();
        }
        return prev + next.toLocaleLowerCase();
	}, '');
}

/* A set of info objects linux packages. E.g.
{
    name: "yarn",
    version: "1.22.5-1",
    annotation: "Yarn"
    poolUrl: "https://dl.yarnpkg.com/debian",
    poolKeyUrl: "https://dl.yarnpkg.com/debian/pubkey.gpg"
}

Defaults to "cgIgnore": true, "markdownIgnore": false given base packages don't need to be registered
*/   
async function getLinuxPackageInfo(imageTagOrContainerName, packageList, linuxDistroInfo) {
    // Merge in default dependencies
    packageList = packageList || [];
    const packageManager = getLinuxPackageManagerForDistro(linuxDistroInfo.id);
    const defaultPackages = configUtils.getDefaultDependencies(packageManager) || [];
    packageList = defaultPackages.concat(packageList);

    // Return empty array if no packages
    if (packageList.length === 0) {
        return [];
    }

    // Get OS info if not passed in
    if(!linuxDistroInfo) {
        linuxDistroInfo = await getLinuxDistroInfo(imageTagOrContainerName);
    }

    // Generate a settings object from packageList
    const settings = packageList.reduce((obj, current) => {
        if(typeof current === 'string') {
            obj[current] = { name: current };
        } else {
            obj[current.name] = current;
        }
        return obj;
    }, {});

    // Space separated list of packages for use in commands
    const packageListCommandPart = packageList.reduce((prev, current) => {
        return prev += ` ${typeof current === 'string' ? current : current.name}`;
    }, '');

    // Use the appropriate package lookup settings for distro
    const extractionConfig = linuxPackageInfoExtractionConfig[packageManager];

    // Generate and exec command to get installed package versions
    console.log('(*) Gathering information about Linux package versions...');
    const packageVersionListOutput = await getCommandOutputFromContainer(imageTagOrContainerName, 
        extractionConfig.listCommand + packageListCommandPart + " || echo 'Some packages were not found.'", true);
   
    // Generate and exec command to extract download URIs
    console.log('(*) Gathering information about Linux package download URLs...');
    const packageUriCommandOutput = await getCommandOutputFromContainer(imageTagOrContainerName, 
        extractionConfig.getUriCommand + packageListCommandPart + " || echo 'Some packages were not found.'", true);

    const componentList = [];
    const packageVersionList = packageVersionListOutput.split('\n');
    packageVersionList.forEach((packageVersion) => {
        packageVersion = packageVersion.trim();
        if (packageVersion !== '') {
            const versionCaptureGroup = new RegExp(extractionConfig.lineRegEx).exec(packageVersion);
            if (!versionCaptureGroup) {
                if(packageVersion === 'Some packages were not found.') {
                    console.log('(!) Warning: Some specified packages were not found.');
                } else {
                    console.log(`(!) Warning: Unable to parse output "${packageVersion}" - skipping.`);
                }
                return;
            }
            const [, package, version ] = versionCaptureGroup;
            const packageSettings = settings[package] || {};
            const cgIgnore =  typeof packageSettings.cgIgnore === 'undefined' ? true : packageSettings.cgIgnore; // default to true
            const poolUrl = getPoolUrlFromPackageVersionListOutput(packageUriCommandOutput, extractionConfig, package, version);
            if(!cgIgnore && !poolUrl) {
                throw new Error('(!) No pool URL found to register package!');
            }
            componentList.push({
                name: package,
                version: version,
                poolUrl: poolUrl,
                poolKeyUrl: configUtils.getPoolKeyForPoolUrl(poolUrl),
                annotation: packageSettings.annotation,
                cgIgnore: cgIgnore,
                markdownIgnore: packageSettings.markdownIgnore
            });
        }
    });

    return componentList;
}

// Gets a package pool URL out of a download URL - Needed for registering in cgmanifest.json
function getPoolUrlFromPackageVersionListOutput(packageUriCommandOutput, config, package, version) {
    // Handle regex reserved charters in regex strings and that ":" is treaded as "1%3a" on Debian/Ubuntu 
    const sanitizedPackage = package.replace(/\+/g, '\\+').replace(/\./g, '\\.');
    const sanitizedVersion = version.replace(/\+/g, '\\+').replace(/\./g, '\\.').replace(/:/g, '%3a');
    const uriCaptureGroup = new RegExp(
        config.poolUriMatchRegEx.replace('${PACKAGE}', sanitizedPackage).replace('${VERSION}', sanitizedVersion), 'm')
        .exec(packageUriCommandOutput);

    if (!uriCaptureGroup) {
        const fallbackPoolUrl = configUtils.getFallbackPoolUrl(package);
        if (fallbackPoolUrl) {
            return fallbackPoolUrl;
        } 
        console.log(`(!) No URI found for ${package} ${version}.`);
        return null;
    }

    // Extract URIs
    return uriCaptureGroup[1];
}

/* Generate "Npm" info objects. E.g.
{
    name: "eslint",
    version: "7.23.0"
}
*/
async function getNpmGlobalPackageInfo(imageTagOrContainerName, packageList) {
    // Merge in default dependencies
    packageList = packageList || [];
    const defaultPackages = configUtils.getDefaultDependencies('npm') || [];
    packageList = defaultPackages.concat(packageList);
    
    // Return empty array if no packages
    if (packageList.length === 0) {
        return [];
    }

    console.log(`(*) Gathering information about globally installed npm packages...`);

    const packageListString = packageList.reduce((prev, current) => prev + ' ' + current, '');
    const npmOutputRaw = await getCommandOutputFromContainer(imageTagOrContainerName, `bash -l -c 'set -e && npm ls --global --depth 1 --json ${packageListString}' 2>/dev/null`);
    const npmOutput = JSON.parse(npmOutputRaw);

    return packageList.map((package) => {
        let packageJson =  npmOutput.dependencies[package];
        if (!packageJson) {
            // Possible desired package is referenced by another top level package, so check dependencies too.
            // E.g. tslint-to-eslint-config can cause typescript to not appear at top level in npm ls
            for (let packageInNpmOutput in npmOutput.dependencies) {
                const packageDependencies = npmOutput.dependencies[packageInNpmOutput].dependencies;
                if(packageDependencies) {
                    packageJson = packageDependencies[package];
                    if(packageJson) {
                        break;
                    }    
                }
            }
        }
        if(!packageJson || !packageJson.version) {
            throw new Error(`Unable to parse version for ${package} from npm ls output: ${npmOutputRaw}`);
        }
        return {
            name: package,
            version:packageJson.version
        }
    });
}


/* Generate pip or pipx info objects. E.g.
{
    name: "pylint",
    version: "2.6.0"
}
*/
async function getPipPackageInfo(imageTagOrContainerName, packageList, usePipx) {
    // Merge in default dependencies
    packageList = packageList || [];
    const defaultPackages = configUtils.getDefaultDependencies(usePipx ? 'pipx' : 'pip') || [];
    packageList = defaultPackages.concat(packageList);
    
    // Return empty array if no packages
    if (packageList.length === 0) {
        return [];
    }

    // Generate and exec command to get installed package versions
    console.log('(*) Gathering information about pip packages...');
    const versionLookup = usePipx ? await getPipxVersionLookup(imageTagOrContainerName) : await getPipVersionLookup(imageTagOrContainerName);

    return packageList.map((package) => {
        return {
            name: package,
            version: versionLookup[package]
        };
    });
}

async function getPipVersionLookup(imageTagOrContainerName) {
    const packageVersionListOutput = await getCommandOutputFromContainer(imageTagOrContainerName, 'pip list --format json');

    const packageVersionList = JSON.parse(packageVersionListOutput);

    return packageVersionList.reduce((prev, current) => {
        prev[current.name] = current.version;
        return prev;
    }, {});
}

async function getPipxVersionLookup(imageTagOrContainerName) {
    // --format json doesn't work with pipx, so have to do text parsing
    const packageVersionListOutput = await getCommandOutputFromContainer(imageTagOrContainerName, 'pipx list');

    const packageVersionListOutputLines = packageVersionListOutput.split('\n');
    return packageVersionListOutputLines.reduce((prev, current) => {
        const versionCaptureGroup = /package\s(.+)\s(.+),/.exec(current);
        if (versionCaptureGroup) {
            prev[versionCaptureGroup[1]] = versionCaptureGroup[2];
        }
        return prev;
    }, {});
}

/* Generate git info objects. E.g.
{
    name: "Oh My Zsh!",
    path: "/home/codespace/.oh-my-zsh",
    repositoryUrl: "https://github.com/ohmyzsh/ohmyzsh.git",
    commitHash: "cddac7177abc358f44efb469af43191922273705"
}
*/
async function getGitRepositoryInfo(imageTagOrContainerName, gitRepos) {
    // Merge in default dependencies
    const defaultPackages = configUtils.getDefaultDependencies('git');
    if(defaultPackages) {
        const merged = defaultPackages;
        for(let otherName in gitRepos) {
            merged[otherName] = gitRepos[otherName];
        }
        gitRepos = merged;
    }
    // Return empty array if no components
    if (!gitRepos) {
        return [];
    }

    const componentList = [];
    for(let repoName in gitRepos) {
        const repoPath = gitRepos[repoName];
        if (typeof repoPath === 'string') {
            console.log(`(*) Getting remote and commit for ${repoName} at ${repoPath}...`);
            // Go to the specified folder, see if the commands have already been run, if not run them and get output
            const remoteAndCommitOutput = await getCommandOutputFromContainer(imageTagOrContainerName, `git config --global --add safe.directory \\"${repoPath}\\" && cd \\"${repoPath}\\" && if [ -f \\".git-remote-and-commit\\" ]; then cat .git-remote-and-commit; else git remote get-url origin && git log -n 1 --pretty=format:%H -- . | tee /dev/null; fi`,true);
            const [gitRemote, gitCommit] = remoteAndCommitOutput.split('\n');
            componentList.push({
                name: repoName,
                path: repoPath,
                repositoryUrl: gitRemote,
                commitHash: gitCommit
            });
        }
    }

    return componentList;
}

/* Generate "other" info objects. E.g.
{
    name: "Xdebug",
    version: "2.9.6",
    downloadUrl: "https://pecl.php.net/get/xdebug-2.9.6.tgz"
}
*/
async function getOtherComponentInfo(imageTagOrContainerName, otherComponents, otherType) {
    otherType = otherType || 'other';
    // Merge in default dependencies
    const defaultPackages = configUtils.getDefaultDependencies(otherType);
    if(defaultPackages) {
        const merged = defaultPackages;
        for(let otherName in otherComponents) {
            merged[otherName] = otherComponents[otherName];
        }
        otherComponents = merged;
    }
    // Return empty array if no components
    if (!otherComponents) {
        return [];
    }

    console.log(`(*) Gathering information about "other" components...`);
    const componentList = [];
    for(let otherName in otherComponents) {
        const otherSettings = mergeOtherDefaultSettings(otherName, otherComponents[otherName]);
        if (typeof otherSettings === 'object') {
            console.log(`(*) Getting version for ${otherName}...`);
            // Run specified command to get the version number
            const otherVersion = (await getCommandOutputFromContainer(imageTagOrContainerName, otherSettings.versionCommand));
            componentList.push({
                name: otherName,
                version: otherVersion,
                downloadUrl: otherSettings.downloadUrl,
                path: otherSettings.path,
                annotation: otherSettings.annotation,
                cgIgnore: otherSettings.cgIgnore,
                markdownIgnore: otherSettings.markdownIgnore
            });
         }
    }

    return componentList;
}

// Merge in default config for specified otherName if it exists
function mergeOtherDefaultSettings(otherName, settings) {
    const otherDefaultSettings = configUtils.getConfig('otherDependencyDefaultSettings', null);
    if (!otherDefaultSettings || !otherDefaultSettings[otherName] ) {
        return settings;
    }
    // Create a copy of default settings for merging
    const mergedSettings = Object.assign({}, otherDefaultSettings[otherName]);
    settings = settings || {};
    for (let settingName in settings) {
        mergedSettings[settingName] = settings[settingName];
    }
    return mergedSettings;
}

/* Generate Ruby gems info objects. E.g.
{
    name: "rake",
    version: "13.0.1"
}
*/
async function getGemPackageInfo(imageTagOrContainerName, packageList) {
    // Merge in default dependencies
    packageList = packageList || [];
    const defaultPackages = configUtils.getDefaultDependencies('gem') || [];
    packageList = defaultPackages.concat(packageList);
    
    // Return empty array if no packages
    if (packageList.length === 0) {
        return [];
    }

    console.log(`(*) Gathering information about gems...`);
    const gemListOutput = await getCommandOutputFromContainer(imageTagOrContainerName, "bash -l -c 'set -e && gem list -d --local' 2>/dev/null");
    return packageList.map((gem) => {
        const gemVersionCaptureGroup = new RegExp(`^${gem}\\s\\(([^\\),]+)`,'m').exec(gemListOutput);
        const gemVersion = gemVersionCaptureGroup[1];
        return {
            name: gem,
            version: gemVersion
        }
    });
}

/* Generate cargo info object. E.g.
{
    name: "rustfmt",
    version: "1.4.17-stable"
}
*/
async function getCargoPackageInfo(imageTagOrContainerName, packages) {
    // Merge in default dependencies
    const defaultPackages = configUtils.getDefaultDependencies('go');
    if(defaultPackages) {
        const merged = defaultPackages;
        for(let package in packages) {
            merged[package] = packages[package];
        }
        packages = merged;
    }
    // Return empty array if no packages
    if (!packages) {
        return [];
    }

    const componentList = [];
    console.log(`(*) Gathering information about cargo packages...`);

    for(let crate in packages) {
        if (typeof crate === 'string') {
            const versionCommand = packages[crate] || `${crate} --version`;
            console.log(`(*) Getting version for ${crate}...`);
            const versionOutput = await getCommandOutputFromContainer(imageTagOrContainerName, versionCommand);
            const crateVersionCaptureGroup = new RegExp('[0-9]+\\.[0-9]+\\.[0-9]+','m').exec(versionOutput);
            const version = crateVersionCaptureGroup[0];
            componentList.push({
                name: crate,
                version: version
            });
        }
    }

    return componentList;
}

/* Generate go info objects. E.g.
{
    name: "golang.org/x/tools/gopls",
    version: "0.6.4"
}
*/
async function getGoPackageInfo(imageTagOrContainerName, packages) {
    // Merge in default dependencies
    const defaultPackages = configUtils.getDefaultDependencies('go');
    if(defaultPackages) {
        const merged = defaultPackages;
        for(let package in packages) {
            merged[package] = packages[package];
        }
        packages = merged;
    }
    // Return empty array if no components
    if (!packages) {
        return [];
    }

    console.log(`(*) Gathering information about go modules and packages...`);
    const componentList = [];
    const packageInstallOutput = await getCommandOutputFromContainer(imageTagOrContainerName, "cat /usr/local/etc/vscode-dev-containers/go.log");
    for(let package in packages) {
        if (typeof package === 'string') {
            const versionCommand = packages[package];
            let version;
            if(versionCommand) {
                version = await getCommandOutputFromContainer(imageTagOrContainerName, versionCommand);
            } else {
                const versionCaptureGroup = new RegExp(`downloading\\s*${package}\\s*v([0-9]+\\.[0-9]+\\.[0-9]+.*)\\n`).exec(packageInstallOutput);
                version = versionCaptureGroup ? versionCaptureGroup[1] : 'latest';
            }
            componentList.push({
                name: package,
                version: version
            });
        }
    }

    return componentList;
}

/* Generate image info object. E.g.
{
    "name": "debian"
    "digest": "sha256:c33d4c1938625a1d0cda78102127b81935e0e94785bc4810b71b5f236dd935e"
}
*/
async function getImageInfo(imageTagOrContainerName) {
    let image = imageTagOrContainerName;
    if(isContainerName(imageTagOrContainerName)) {
        image = await asyncUtils.spawn('docker', ['inspect', "--format='{{.Image}}'", imageTagOrContainerName.trim()], { shell: true, stdio: 'pipe' });
    }
    // If image not yet published, there will be no repo digests, so set to N/A if that is the case
    let name, digest;
    try {
        const imageNameAndDigest = await asyncUtils.spawn('docker', ['inspect', "--format='{{index .RepoDigests 0}}'", image], { shell: true, stdio: 'pipe' });
        [name, digest] = imageNameAndDigest.trim().split('@');
    } catch(err) {
        if(err.result.indexOf('Template parsing error') > 0) {
            name = 'N/A';
            digest = 'N/A';
        } else {
            throw err;
        }
    }
    const nonRootUser = await getCommandOutputFromContainer(imageTagOrContainerName, 'id -un 1000', true)
    return {
        "name": name,
        "digest": digest,
        "user": nonRootUser
    }
}


// Command to start a container for processing. Returns a container name with a 
// specific format that can be used to detect whether an image tag or container
// name is passed into the content extractor functions.
async function startContainerForProcessing(imageTag) {
    const containerName = `vscdc--extract--${Date.now()}`;
    await asyncUtils.spawn('docker', ['run', '-d', '--rm', '--init', '--privileged', '--name', containerName, imageTag, 'sh -c "while sleep 1000; do :; done"'], { shell: true, stdio: 'inherit' });
    return containerName;
}

// Removes the specified container
async function removeProcessingContainer(containerName) {
    await asyncUtils.spawn('docker', ['rm', '-f', containerName], { shell: true, stdio: 'inherit' });
}

// Utility that executes commands inside a container. If a specially formatted container 
// name is passed in, the function will use "docker exec" and otherwise use "docker run" 
// since this means an image tag was passed in instead.
async function getCommandOutputFromContainer(imageTagOrContainerName, command, forceRoot) {
    const runArgs = isContainerName(imageTagOrContainerName) ?
        ['exec'].concat(forceRoot ? ['-u', 'root'] : [])
        : ['run','--init', '--privileged', '--rm'].concat(forceRoot ? ['-u', 'root'] : []);
    const wrappedCommand = `bash -c "set -e && echo ~~~BEGIN~~~ && ${command} && echo && echo ~~~END~~~"`;
    runArgs.push(imageTagOrContainerName);
    runArgs.push(wrappedCommand);
    const result = await asyncUtils.spawn('docker', runArgs, { shell: true, stdio: 'pipe' });
    // Filter out noise from ENTRYPOINT output
    const filteredResult = result.substring(result.indexOf('~~~BEGIN~~~') + 11, result.indexOf('~~~END~~~'));
    return filteredResult.trim();
}

function isContainerName(imageTagOrContainerName) {
    return (imageTagOrContainerName.indexOf('vscdc--extract--') === 0)
}

// Use distro "ID" from /etc/os-release to determine appropriate package manger
function getLinuxPackageManagerForDistro(distroId)
{
    switch(distroId) {
        case 'apt':
        case 'debian':
        case 'ubuntu': return 'apt';
        case 'apk':
        case 'alpine': return 'apk';
    }
    return null;
}

// Return dependencies by mapping distro "ID" from /etc/os-release to determine appropriate package manger
function getLinuxPackageManagerDependencies(dependencies, distroInfo) {
    if(dependencies[distroInfo.id]) {
        return dependencies[distroInfo.id];
    } 
    return dependencies[getLinuxPackageManagerForDistro(distroInfo.id)]
}

// Spins up a container for a referenced image and extracts info for the specified dependencies
async function getAllContentInfo(imageTag, dependencies) {
    const containerName = await startContainerForProcessing(imageTag);
    try {
        const distroInfo = await getLinuxDistroInfo(containerName);
        const contents = {
            image: await getImageInfo(containerName),
            distro: distroInfo,
            linux: await getLinuxPackageInfo(containerName, getLinuxPackageManagerDependencies(dependencies, distroInfo), distroInfo),
            npm: await getNpmGlobalPackageInfo(containerName, dependencies.npm),
            pip: await getPipPackageInfo(containerName, dependencies.pip, false),
            pipx: await getPipPackageInfo(containerName, dependencies.pipx, true),
            gem: await getGemPackageInfo(containerName, dependencies.gem),
            cargo: await getCargoPackageInfo(containerName, dependencies.cargo),
            go: await getGoPackageInfo(containerName, dependencies.go),
            git: await getGitRepositoryInfo(containerName, dependencies.git),
            other: await getOtherComponentInfo(containerName, dependencies.other, 'other'),
            languages: await getOtherComponentInfo(containerName, dependencies.languages, 'languages'),
            manual: dependencies.manual
        }    
        await removeProcessingContainer(containerName);
        return contents;
    } catch (e) {
        await removeProcessingContainer(containerName);
        throw e;
    }
}

module.exports = {
    getImageInfo: getImageInfo,
    getLinuxDistroInfo: getLinuxDistroInfo,
    getLinuxPackageInfo: getLinuxPackageInfo,
    getNpmGlobalPackageInfo: getNpmGlobalPackageInfo,
    getPipPackageInfo: getPipPackageInfo,
    getGemPackageInfo: getGemPackageInfo,
    getCargoPackageInfo: getCargoPackageInfo,
    getGoPackageInfo: getGoPackageInfo,
    getGitRepositoryInfo: getGitRepositoryInfo,
    getOtherComponentInfo: getOtherComponentInfo,
    startContainerForProcessing: startContainerForProcessing,
    removeProcessingContainer: removeProcessingContainer,
    getAllContentInfo: getAllContentInfo
}
