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
        listCommand: "dpkg-query --show -f='${Package}\\t${Version}\\n'",
        lineRegEx: /(.+)\t(.+)/,
        getUriCommand: 'apt-get update && apt-get install -y --reinstall --print-uris',
        uriMatchRegex: "'(.+)'\\s*${PACKAGE}_${VERSION}"
    },
    ubuntu: {
        // Command to get package versions: dpkg-query --show -f='${Package}\t${Version}\n' <package>
        // Output: <package>    <version>
        // Command to get download URLs: apt-get update && apt-get install -y --reinstall --print-uris
        namePrefix: 'Ubuntu Package:',
        listCommand: "dpkg-query --show -f='${Package}\\t${Version}\\n'",
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

async function generateComponentGovernanceManifest(repo, release, registry, registryPath, buildFirst, pruneBetweenDefinitions, definitionId) {
    // Load config files
    await configUtils.loadConfig();

    const alreadyRegistered = {};
    const cgManifest = {
        "Registrations": [],
        "Version": 1
    }

    console.log('(*) Generating manifest...');
    const definitions = definitionId ? [definitionId] : configUtils.getSortedDefinitionBuildList();
    await asyncUtils.forEach(definitions, async (current) => {
        cgManifest.Registrations = cgManifest.Registrations.concat(
            await getDefinitionManifest(repo, release, registry, registryPath, current, alreadyRegistered, buildFirst));
        // Prune images if setting enabled
        if (pruneBetweenDefinitions) {
            await asyncUtils.spawn('docker', ['image', 'prune', '-a']);
        }
    });

    console.log('(*) Writing manifest...');
    await asyncUtils.writeFile(
        path.join(__dirname, '..', '..', 'cgmanifest.json'),
        JSON.stringify(cgManifest, undefined, 4))
    console.log('(*) Done!');
}

async function getDefinitionManifest(repo, release, registry, registryPath, definitionId, alreadyRegistered, buildFirst) {
    const dependencies = configUtils.getDefinitionDependencies(definitionId);
    if (typeof dependencies !== 'object') {
        return [];
    }

    // Docker image to use to determine installed package versions
    const imageTag = configUtils.getTagsForVersion(definitionId, 'dev', registry, registryPath)[0]

    if (buildFirst) {
        // Build but don't push images
        console.log('(*) Building images...');
        await push(repo, release, false, registry, registryPath, registry, registryPath, false, false, [], 1, 1, false, definitionId);
    } else {
        console.log(`(*) Pulling image ${imageTag}...`);
        await asyncUtils.spawn('docker', ['pull', imageTag]);
    }

    const registrations = [];

    // For each image variant...
    await asyncUtils.forEach(dependencies.imageVariants, (async (imageTag) => {

        /* Old logic for DockerImage type
        // Pull base images
        console.log(`(*) Pulling image ${imageTag}...`);
        await asyncUtils.spawn('docker', ['pull', imageTag]);
        const digest = await getImageDigest(imageTag);
        // Add Docker image registration
        if (typeof alreadyRegistered[imageTag] === 'undefined') {
            const [image, imageVersion] = imageTag.split(':');
            registrations.push({
                "Component": {
                    "Type": "DockerImage",
                    "DockerImage": {
                        "Name": image,
                        "Digest": digest,
                        "Tag":imageVersion
                      }
                }
            });
            */
        if (typeof alreadyRegistered[imageTag] === 'undefined') {
            const [image, imageVersion] = imageTag.split(':');
            registrations.push({
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
    }));

    // Run commands in the package to pull out needed versions
    return registrations.concat(
        await generatePackageComponentList(dependencyLookupConfig.debian, dependencies.debian, imageTag, alreadyRegistered),
        await generatePackageComponentList(dependencyLookupConfig.ubuntu, dependencies.ubuntu, imageTag, alreadyRegistered),
        await generatePackageComponentList(dependencyLookupConfig.alpine, dependencies.alpine, imageTag, alreadyRegistered),
        await generateGitComponentList(dependencies.git, imageTag, alreadyRegistered),
        await generateNpmComponentList(dependencies.npm, alreadyRegistered),
        await generatePipComponentList(dependencies.pip, imageTag, alreadyRegistered),
        await generatePipComponentList(dependencies.pipx, imageTag, alreadyRegistered, true),
        await generateGemComponentList(dependencies.gem, imageTag, alreadyRegistered),
        await generateCargoComponentList(dependencies.cargo, imageTag, alreadyRegistered),
        await generateOtherComponentList(dependencies.other, imageTag, alreadyRegistered),
        filteredManualComponentRegistrations(dependencies.manual, alreadyRegistered));
}

async function generatePackageComponentList(config, packageList, imageTag, alreadyRegistered) {
    if (!packageList) {
        return [];
    }

    const componentList = [];
    console.log(`(*) Generating Linux package registrations for ${imageTag}...`);

    // Generate and exec command to get installed package versions
    console.log('(*) Getting package versions...');
    const packageVersionListCommand = packageList.reduce((prev, current) => {
        return prev += ` ${current}`;
    }, config.listCommand);
    const packageVersionListOutput = await getDockerRunCommandOutput(imageTag, packageVersionListCommand, true);

    // Generate and exec command to extract download URIs
    console.log('(*) Getting package download URLs...');
    const packageUriCommand = packageList.reduce((prev, current) => {
        return prev += ` ${current}`;
    }, config.getUriCommand);
    const packageUriCommandOutput = await getDockerRunCommandOutput(imageTag, `sh -c '${packageUriCommand}'`, true);

    const packageVersionList = packageVersionListOutput.split('\n');
    packageVersionList.forEach((packageVersion) => {
        packageVersion = packageVersion.trim();
        if (packageVersion !== '') {
            const versionCaptureGroup = new RegExp(config.lineRegEx).exec(packageVersion);
            if (!versionCaptureGroup) {
                console.log(`(!) Warning: Unable to parse output "${packageVersion}". Likely not from command. Skipping.`);
            } else {
                const package = versionCaptureGroup[1];
                const version = versionCaptureGroup[2];    
                const entry = createEntryForLinuxPackage(packageUriCommandOutput, config.namePrefix, package, version, alreadyRegistered, config.uriMatchRegex, config.uriSuffix)
                if (entry) {
                    componentList.push(entry);
                }    
            }
        }
    });

    return componentList;
}

/* Generate "Other" entry for linux packages. E.g.
{
    "Component": {
        "Type": "other",
        "Other": {
            "Name": "Debian Package: apt-transport-https",
            "Version": "1.8.2.1",
            "DownloadUrl": "http://deb.debian.org/debian/pool/main/a/apt/apt-transport-https_1.8.2.1_all.deb"
        }
    }
}
*/
function createEntryForLinuxPackage(packageUriCommandOutput, entryNamePrefix, package, version, alreadyRegistered, uriMatchRegex, uriSuffix) {
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

/* Generate "Npm" entries. E.g.
{
    "Component": {
        "Type": "npm",
        "Npm": {
            "Name": "eslint",
            "Version": "7.7.0"
        }
    }
}
*/
async function generateNpmComponentList(packageList, alreadyRegistered) {
    if (!packageList) {
        return [];
    }

    console.log(`(*) Generating "npm" registrations...`);

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
        addIfUnique(`${package}-npm`, version, componentList, alreadyRegistered, {
            "Component": {
                "Type": "npm",
                "Npm": {
                    "Name": package,
                    "Version": version
                }
            }
        });
    });
    return componentList;
}


/* Generate "Pip" entries. E.g.
{
    "Component": {
        "Type": "Pip",
        "Pip": {
            "Name": "pylint",
            "Version": "2.6.0"
        }
    }
}
*/
async function generatePipComponentList(packageList, imageTag, alreadyRegistered, pipx) {
    if (!packageList) {
        return [];
    }

    const componentList = [];
    console.log(`(*) Generating "Pip" registries...`);

    // Generate and exec command to get installed package versions
    console.log('(*) Getting package versions...');
    const versionLookup = pipx ? await getPipxVersionLookup(imageTag) : await getPipVersionLookup(imageTag);

    packageList.forEach((package) => {
        const version = versionLookup[package];
        const uniquePackageName = `pip-${package}`;
        addIfUnique(uniquePackageName, version, componentList, alreadyRegistered, {
            "Component": {
                "Type": "Pip",
                "Pip": {
                    "Name": package,
                    "Version": version
                }
            }
        });
    });

    return componentList;
}

async function getPipVersionLookup(imageTag) {
    const packageVersionListOutput = await getDockerRunCommandOutput(imageTag, 'pip list --format json');

    const packageVersionList = JSON.parse(packageVersionListOutput);

    return packageVersionList.reduce((prev, current) => {
        prev[current.name] = current.version;
        return prev;
    }, {});
}

async function getPipxVersionLookup(imageTag) {
    // --format json doesn't work with pipx, so have to do text parsing
    const packageVersionListOutput = await getDockerRunCommandOutput(imageTag, 'pipx list');

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
    "Component": {
        "Type": "git",
        "Git": {
            "Name": "Oh My Zsh!",
            "repositoryUrl": "https://github.com/ohmyzsh/ohmyzsh.git",
            "commitHash": "cddac7177abc358f44efb469af43191922273705"
        }
    }
}
*/
async function generateGitComponentList(gitRepoPath, imageTag, alreadyRegistered) {
    if (!gitRepoPath) {
        return [];
    }

    const componentList = [];
    console.log(`(*) Generating "git" registrations...`);

    for(let repoName in gitRepoPath) {
        const repoPath = gitRepoPath[repoName];
        if (typeof repoPath === 'string') {
            console.log(`(*) Getting remote and commit for ${repoName} at ${repoPath}...`);
            // Go to the specified folder, see if the commands have already been run, if not run them and get output
            const remoteAndCommitOutput = await getDockerRunCommandOutput(imageTag, `bash -c "set -e && cd \\"${repoPath}\\" && if [ -f ".git-remote-and-commit" ]; then cat .git-remote-and-commit; else git remote get-url origin && echo $(git log -n 1 --pretty=format:%H -- .); fi"`);
            const remoteAndCommit = remoteAndCommitOutput.split('\n');
            const gitRemote = remoteAndCommit[0];
            const gitCommit = remoteAndCommit[1];
            addIfUnique(`${gitRemote}-git`, gitCommit, componentList, alreadyRegistered, {
                "Component": {
                    "Type": "git",
                    "Git": {
                        "Name": repoName,
                        "repositoryUrl": gitRemote,
                        "commitHash": gitCommit
                    }
                }
            });
        }
    }

    return componentList;
}

/* Generate "Other" entries. E.g.
{
    "Component": {
        "Type": "other",
        "Other": {
            "Name": "Xdebug",
            "Version": "2.9.6",
            "DownloadUrl": "https://pecl.php.net/get/xdebug-2.9.6.tgz"
        }
    }
}
*/
async function generateOtherComponentList(otherComponents, imageTag, alreadyRegistered) {
    if (!otherComponents) {
        return [];
    }

    const componentList = [];
    console.log(`(*) Generating "other" registrations...`);

    for(let otherName in otherComponents) {
        const otherSettings = otherComponents[otherName];
        if (typeof otherSettings === 'object') {
            console.log(`(*) Getting version for ${otherName}...`);
            // Run specified command to get the version number
            const otherVersion = (await getDockerRunCommandOutput(imageTag, `bash -c "set -e && ${otherSettings.versionCommand}"`)).trim();
            addIfUnique(`${otherName}-other`, otherVersion, componentList, alreadyRegistered, {
                "Component": {
                    "Type": "other",
                    "Other": {
                        "Name": otherName,
                        "Version": otherVersion,
                        "DownloadUrl": otherSettings.downloadUrl
                    }
                }
            });
        }
    }

    return componentList;
}

/* Generate "RubyGems" entries. E.g.
{
    "Component": {
        "Type": "RubyGems",
        "RubyGems": {
            "Name": "rake",
            "Version": "13.0.1"
        }
    }
}
*/
async function generateGemComponentList(gems, imageTag, alreadyRegistered) {
    if (!gems) {
        return [];
    }

    const componentList = [];
    console.log(`(*) Generating "RubyGems" registrations...`);

    const gemListOutput = await getDockerRunCommandOutput(imageTag, 'bash -l -c "set -e && gem list -d --local"');

    asyncUtils.forEach(gems, (gem) => {
        if (typeof gem === 'string') {
            console.log(`(*) Getting version for ${gem}...`);
            const gemVersionCaptureGroup = new RegExp(`^${gem}\\s\\(([^\\)]+)`,'m').exec(gemListOutput);
            const gemVersion = gemVersionCaptureGroup[1];
            addIfUnique(`${gem}-gem`, gemVersion, componentList, alreadyRegistered, {
                "Component": {
                    "Type": "RubyGems",
                    "RubyGems": {
                        "Name": gem,
                        "Version": gemVersion,
                    }
                }
            });
        }
    });

    return componentList;
}

/* Generate "Cargo" entries. E.g.
{
    "Component": {
        "Type": "cargo",
        "Cargo": {
            "Name": "rustfmt",
            "Version": "1.4.17-stable"
        }
    }
}
*/
async function generateCargoComponentList(crates, imageTag, alreadyRegistered) {
    if (!crates) {
        return [];
    }

    const componentList = [];
    console.log(`(*) Generating "Cargo" registrations...`);

    for(let crate in crates) {
        const versionCommand = crates[crate] || `echo ${crate} \\$(rustc --version | grep -oE '^rustc\\s[^ ]+' | sed -n '/rustc\\s/s///p')`;
        if (typeof versionCommand === 'string') {
            console.log(`(*) Getting version for ${crate}...`);
            const versionOutput = await getDockerRunCommandOutput(imageTag, `bash -c "set -e && ${versionCommand}"`);
            const crateVersionCaptureGroup = new RegExp(`^${crate}\\s([^\\s]+)`,'m').exec(versionOutput);
            const version = crateVersionCaptureGroup[1];
            addIfUnique(`${crate}-cargo`, version, componentList, alreadyRegistered, {
                "Component": {
                    "Type": "cargo",
                    "Cargo": {
                        "Name": crate,
                        "Version": version
                    }
                }
            });
        }
    }

    return componentList;
}



function addIfUnique(uniqueName, uniqueVersion, componentList, alreadyRegistered, componentJson) {
    if (typeof alreadyRegistered[uniqueName] === 'undefined' || alreadyRegistered[uniqueName].indexOf(uniqueVersion) < 0) {
            componentList.push(componentJson);
            alreadyRegistered[uniqueName] = alreadyRegistered[uniqueName] || [];
            alreadyRegistered[uniqueName].push(uniqueVersion);    
    }
    return componentList;
}


function filteredManualComponentRegistrations(manualRegistrations, alreadyRegistered) {
    if (!manualRegistrations) {
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

async function getDockerRunCommandOutput(imageTag, command, forceRoot) {
    const runArgs = ['run','--init', '--privileged', '--rm'].concat(forceRoot ? ['-u', 'root'] : []);
    runArgs.push(imageTag);
    runArgs.push(command);
    const result = await asyncUtils.spawn('docker', runArgs, { shell: true, stdio: 'pipe' });
    // Commands that start on entrypoint can use init.d which outputs in the format ' * <something>\n...done\n', 
    // so filter these out along with unicode or escape / color code characters
    const filteredResult = result.toString()
        .replace(/^(\s\*\s.+\n(.+done.\n)?)+/m,'')
        .replace(/[^\w\W\s]/gm,'');
    return filteredResult;
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

module.exports = {
    generateComponentGovernanceManifest: generateComponentGovernanceManifest
}
