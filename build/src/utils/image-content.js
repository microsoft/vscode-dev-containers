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
    const osInfoCommandOutput = await getDockerRunCommandOutput(imageTagOrContainerName, 'cat /etc/os-release', true);
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

/* Generate "Linux" entry for linux packages. E.g.
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
    if (!packageList) {
        return [];
    }

    const componentList = [];

    // Get OS info if not passed in
    if(!linuxDistroInfo) {
        linuxDistroInfo = await getLinuxDistroInfo(imageTagOrContainerName);
    }

    // Use the appropriate package lookup settings for distro
    const extractionConfig = linuxPackageInfoExtractionConfig[getLinuxPackageManagerForDistro(linuxDistroInfo.id)];

    // Generate a settings object from packageList
    const settings = packageList.reduce((obj, current) => {
        if(typeof current === 'string') {
            obj[current] = { name: current };
        } else {
            obj[current.name] = current;
        }
        return obj;
    }, {});

    // Space separated list of packages for use in com,ands
    const packageListCommandPart = packageList.reduce((prev, current) => {
        return prev += ` ${typeof current === 'string' ? current : current.name}`;
    }, '');

    // Generate and exec command to get installed package versions
    console.log('(*) Gathering information about Linux package versions...');
    const packageVersionListOutput = await getDockerRunCommandOutput(imageTagOrContainerName, extractionConfig.listCommand + packageListCommandPart, true);
   
    // Generate and exec command to extract download URIs
    console.log('(*) Gathering information about Linux package download URLs...');
    const packageUriCommandOutput = await getDockerRunCommandOutput(imageTagOrContainerName, extractionConfig.getUriCommand + packageListCommandPart, true);

    const packageVersionList = packageVersionListOutput.split('\n');
    packageVersionList.forEach((packageVersion) => {
        packageVersion = packageVersion.trim();
        if (packageVersion !== '') {
            const versionCaptureGroup = new RegExp(extractionConfig.lineRegEx).exec(packageVersion);
            if (!versionCaptureGroup) {
                console.log(`(!) Warning: Unable to parse output "${packageVersion}". Likely not from command. Skipping.`);
                return;
            }
            const package = versionCaptureGroup[1];
            const version = versionCaptureGroup[2];
            const packageSettings = settings[package] || {};
            const poolUrl = getPoolUrlFromPackageVersionListOutput(packageUriCommandOutput, extractionConfig, package, version);
            componentList.push({
                name: package,
                version: version,
                poolUrl: poolUrl,
                poolKeyUrl: configUtils.getPoolKeyForPoolUrl(poolUrl),
                annotation: packageSettings.annotation,
                cgIgnore: typeof packageSettings.cgIgnore === 'undefined' ? true : packageSettings.cgIgnore,
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
        console.log(`(!) No URI found for ${package} ${version}. Attempting to use fallback.`);
        const fallbackPoolUrl = configUtils.getFallbackPoolUrl(package);
        if (fallbackPoolUrl) {
            return fallbackPoolUrl;
        } 
        throw new Error('No download URI found for package');
    }

    // Extract URIs
    return uriCaptureGroup[1];
}

/* Generate "Npm" entries. E.g.
{
    name: "eslint",
    version: "7.23.0"
}
*/
async function getNpmGlobalPackageInfo(imageTagOrContainerName, packageList) {
    if (!packageList) {
        return [];
    }

    console.log(`(*) Gathering information about globally installed npm packages...`);

    const npmOutputRaw = await getDockerRunCommandOutput(imageTagOrContainerName, "bash -l -c 'set -e && npm ls --global --depth 0 --json'");
    const npmOutput = JSON.parse(npmOutputRaw);

    return packageList.map((package) => {
        return {
            name: package,
            version: npmOutput.dependencies[package].version
        }
    });
}


/* Generate "Pip" entries. E.g.
{
    name: "pylint",
    version: "2.6.0"
}
*/
async function getPipPackageInfo(imageTagOrContainerName, packageList, usePipx) {
    if (!packageList) {
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
    const packageVersionListOutput = await getDockerRunCommandOutput(imageTagOrContainerName, 'pip list --format json');

    const packageVersionList = JSON.parse(packageVersionListOutput);

    return packageVersionList.reduce((prev, current) => {
        prev[current.name] = current.version;
        return prev;
    }, {});
}

async function getPipxVersionLookup(imageTagOrContainerName) {
    // --format json doesn't work with pipx, so have to do text parsing
    const packageVersionListOutput = await getDockerRunCommandOutput(imageTagOrContainerName, 'pipx list');

    const packageVersionListOutputLines = packageVersionListOutput.split('\n');
    return packageVersionListOutputLines.reduce((prev, current) => {
        const versionCaptureGroup = /package\s(.+)\s(.+),/.exec(current);
        if (versionCaptureGroup) {
            prev[versionCaptureGroup[1]] = versionCaptureGroup[2];
        }
        return prev;
    }, {});
}

/* Generate "Git" entries. E.g.
{
    name: "Oh My Zsh!",
    path: "/home/codespace/.oh-my-zsh",
    repositoryUrl: "https://github.com/ohmyzsh/ohmyzsh.git",
    commitHash: "cddac7177abc358f44efb469af43191922273705"
}
*/
async function getGitRepositoryInfo(imageTagOrContainerName, gitRepoPaths) {
    if (!gitRepoPaths) {
        return [];
    }

    const componentList = [];

    for(let repoName in gitRepoPaths) {
        const repoPath = gitRepoPaths[repoName];
        if (typeof repoPath === 'string') {
            console.log(`(*) Getting remote and commit for ${repoName} at ${repoPath}...`);
            // Go to the specified folder, see if the commands have already been run, if not run them and get output
            const remoteAndCommitOutput = await getDockerRunCommandOutput(imageTagOrContainerName, `cd \\"${repoPath}\\" && if [ -f \\".git-remote-and-commit\\" ]; then cat .git-remote-and-commit; else git remote get-url origin && echo $(git log -n 1 --pretty=format:%H -- .); fi`,true);
            const remoteAndCommit = remoteAndCommitOutput.split('\n');
            const gitRemote = remoteAndCommit[0];
            const gitCommit = remoteAndCommit[1];
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

/* Generate "Other" entries. E.g.
{
    name: "Xdebug",
    version: "2.9.6",
    downloadUrl: "https://pecl.php.net/get/xdebug-2.9.6.tgz"
}
*/
async function getOtherComponentInfo(imageTagOrContainerName, otherComponents) {
    if (!otherComponents) {
        return [];
    }

    if(typeof otherComponents === 'string') {
        otherComponents = [otherComponents];
    }

    const componentList = [];
    console.log(`(*) Gathering information about "other" components...`);

    for(let otherName in otherComponents) {
        const otherSettings = otherComponents[otherName];
        if (typeof otherSettings === 'object') {
            console.log(`(*) Getting version for ${otherName}...`);
            // Run specified command to get the version number
            const otherVersion = (await getDockerRunCommandOutput(imageTagOrContainerName, otherSettings.versionCommand));
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

/* Generate "RubyGems" entries. E.g.
{
    name: "rake",
    version: "13.0.1"
}
*/
async function getGemPackageInfo(imageTagOrContainerName, gems) {
    if (!gems) {
        return [];
    }

    console.log(`(*) Gathering information about gems...`);

    const gemListOutput = await getDockerRunCommandOutput(imageTagOrContainerName, "bash -l -c 'set -e && gem list -d --local'");
    return gems.map((gem) => {
        const gemVersionCaptureGroup = new RegExp(`^${gem}\\s\\(([^\\)]+)`,'m').exec(gemListOutput);
        const gemVersion = gemVersionCaptureGroup[1];
        return {
            name: gem,
            version: gemVersion
        }
    });
}

/* Generate "Cargo" entries. E.g.
{
    name: "rustfmt",
    version: "1.4.17-stable"
}
*/
async function getCargoPackageInfo(imageTagOrContainerName, crates) {
    if (!crates) {
        return [];
    }

    const componentList = [];
    console.log(`(*) Gathering information about cargo packages...`);

    for(let crate in crates) {
        if (typeof crate === 'string') {
            const versionCommand = crates[crate] || `${crate} --version`;
            console.log(`(*) Getting version for ${crate}...`);
            const versionOutput = await getDockerRunCommandOutput(imageTagOrContainerName, versionCommand);
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

/* Generate "Go" entries. E.g.
{
    name: "golang.org/x/tools/gopls",
    version: "0.6.4"
}
*/
async function getGoPackageInfo(imageTagOrContainerName, packages) {
    if (!packages) {
        return [];
    }

    const componentList = [];
    console.log(`(*) Gathering information about go modules and packages...`);

    const packageInstallOutput = await getDockerRunCommandOutput(imageTagOrContainerName, "cat /usr/local/etc/vscode-dev-containers/go.log");
    for(let package in packages) {
        if (typeof package === 'string') {
            const versionCommand = packages[package];
            let version;
            if(versionCommand) {
                version = await getDockerRunCommandOutput(imageTagOrContainerName, versionCommand);
            } else {
                const versionCaptureGroup = new RegExp(`${package}\\s.*v([0-9]+\\.[0-9]+\\.[0-9]+.*)\\n`,'m').exec(packageInstallOutput);
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
async function getDockerRunCommandOutput(imageTagOrContainerName, command, forceRoot) {
    const runArgs = imageTagOrContainerName.indexOf('vscdc--extract--') === 0 ?
        ['exec'].concat(forceRoot ? ['-u', 'root'] : [])
        : ['run','--init', '--privileged', '--rm'].concat(forceRoot ? ['-u', 'root'] : []);
    const wrappedCommand = `bash -c "set -e && echo ~~~BEGIN~~~ && ${command} && echo ~~~END~~~"`;
    runArgs.push(imageTagOrContainerName);
    runArgs.push(wrappedCommand);
    const result = await asyncUtils.spawn('docker', runArgs, { shell: true, stdio: 'pipe' });
    // Filter out noise from ENTRYPOINT output
    const filteredResult = result.substring(result.indexOf('~~~BEGIN~~~') + 11, result.indexOf('~~~END~~~'));
    return filteredResult.trim();
}

/*
async function getImageDigest(imageTag) {
    const commandOutput = await asyncUtils.spawn('docker',
        ['inspect', "--format='{{index .RepoDigests 0}}'", imageTag],
        { shell: true, stdio: 'pipe' });
    // Example output: ruby@sha256:0b503bc5b8cbe2a1e24f122abb4d6c557c21cb7dae8adff1fe0dcad76d606215
    return commandOutput.split('@')[1].trim();
}
*/

// Convert 
function getLinuxPackageManagerForDistro(distroId)
{
    switch(distroId) {
        case 'debian', 'ubuntu': return 'apt';
        case 'alpine': return 'apk';
    }
}

// Spins up a container for a referenced image and extracts info for the specified dependencies
async function getAllContentInfo(imageTag, dependencies) {
    const containerName = await startContainerForProcessing(imageTag);
    const distroInfo = await getLinuxDistroInfo(containerName);
    const contents = {
        distro: distroInfo,
        linux: await getLinuxPackageInfo(containerName, dependencies[getLinuxPackageManagerForDistro(distroInfo.id)], distroInfo),
        npm: await getNpmGlobalPackageInfo(containerName, dependencies.npm),
        pip: await getPipPackageInfo(containerName, dependencies.pip, false),
        pipx: await getPipPackageInfo(containerName, dependencies.pipx, true),
        gem: await getGemPackageInfo(containerName, dependencies.gem),
        cargo: await getCargoPackageInfo(containerName, dependencies.cargo),
        go: await getGoPackageInfo(containerName, dependencies.go),
        git: await getGitRepositoryInfo(containerName, dependencies.git),
        other: await getOtherComponentInfo(containerName, dependencies.other),
        languages: await getOtherComponentInfo(containerName, dependencies.languages),
        manual: dependencies.manual
    }
    await asyncUtils.spawn('docker', ['rm', '-f', containerName], { shell: true, stdio: 'inherit' });
    return contents;
}

module.exports = {
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
