const path = require('path');
const push = require('./push').push;
const asyncUtils = require('./utils/async');
const configUtils = require('./utils/config');
const imageContentUtils = require('./utils/image-content');
const componentFormatterFactory = require('./utils/component-formatter-factory');

//TODO: Generate markdown of versions per image that can then be stored with the definitions on release as a different output format.
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
        JSON.stringify(cgManifest, undefined, 4));
    console.log('(*) Done!');
}

async function getDefinitionManifest(repo, release, registry, registryPath, definitionId, alreadyRegistered, buildFirst) {
    const dependencies = configUtils.getDefinitionDependencies(definitionId);
    if (typeof dependencies !== 'object') {
        return [];
    }

    // Docker image to use to determine installed package versions
    const version = configUtils.getVersionFromRelease(release);
    const imageTag = configUtils.getTagsForVersion(definitionId, version, registry, registryPath)[0]

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

    const contents = await imageContentUtils.getAllContentInfo(imageTag, dependencies);
    const componentFormatter = componentFormatterFactory.getFormatter(contents.distro);
    return registrations.concat(
        getUniqueComponents(alreadyRegistered, contents, componentFormatter),
        filteredManualComponentRegistrations(alreadyRegistered, dependencies.manual));
}

// Filter out components already in the registration list and format output returns an array of formatted and filtered contents
function getUniqueComponents(alreadyRegistered, contents, contentFormatter) {
    let componentList = [];
    for (let contentType in contents) {
        const formatterFn = contentFormatter[contentType];
        if (formatterFn) {
            const contentList = contents[contentType];
            componentList = componentList.concat(contentList.reduce((prev, next) => {
                const uniqueId = JSON.stringify(next);
                if(!alreadyRegistered[uniqueId]) {
                    alreadyRegistered[uniqueId] = true;
                    const component = formatterFn(next);
                    prev.push(component);
                }
                return prev;
            }, []));
        }
    }
    
    return componentList;
}


function filteredManualComponentRegistrations(alreadyRegistered, manualRegistrations) {
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
