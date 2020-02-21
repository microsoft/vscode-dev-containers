/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

const os = require('os');
const path = require('path');
const asyncUtils = require('./async');
const jsonc = require('jsonc').jsonc;
const config = require('../../config.json');

config.definitionDependencies = config.definitionDependencies || {};
config.definitionBuildSettings = config.definitionBuildSettings || {};
config.definitionVersions = config.definitionVersions || {};

const stagingFolders = {};
const definitionTagLookup = {};

// Must be called first
async function loadConfig(repoPath) {
    repoPath = repoPath || path.join(__dirname, '..', '..', '..');

    const containersPath = path.join(repoPath, getConfig('containersPathInRepo', 'containers'));
    // Get list of definition folders
    const definitions = await asyncUtils.readdir(containersPath, { withFileTypes: true });
    await asyncUtils.forEach(definitions, async (definitionFolder) => {
        if (!definitionFolder.isDirectory()) {
            return;
        }
        const definitionId = definitionFolder.name;
        // If definition-build.json exists, load it
        const possibleDefinitionBuildJson = path.join(containersPath, definitionId, getConfig('definitionBuildConfigFile', 'definition-build.json'));
        if (await asyncUtils.exists(possibleDefinitionBuildJson)) {
            const buildJson = await jsonc.read(possibleDefinitionBuildJson);
            if (buildJson.build) {
                config.definitionBuildSettings[definitionId] = buildJson.build;
            }
            if (buildJson.dependencies) {
                config.definitionDependencies[definitionId] = buildJson.dependencies;
            }
            if(buildJson.definitionVersion) {
                config.definitionVersions[definitionId] = buildJson.definitionVersion;
            }
        }
    });

    // Populate image variants and tag lookup
    for (let definitionId in config.definitionBuildSettings) {
        const buildSettings = config.definitionBuildSettings[definitionId];
        const variants = buildSettings.variants || [undefined];
        const dependencies = config.definitionDependencies[definitionId]; 
 
        // Populate images list for variants
        dependencies.imageVariants = buildSettings.variants ? 
            variants.map((variant) => dependencies.image.replace('${VARIANT}', variant)) :
            [dependencies.image];

        // Populate image tag lookup
        if (buildSettings.tags) {
            variants.forEach((variant) => {
                const blankTagList = getTagsForVersion(definitionId, '', 'ANY', 'ANY', variant);
                blankTagList.forEach((blankTag) => {
                    definitionTagLookup[blankTag] = definitionId;
                });
                const devTagList = getTagsForVersion(definitionId, 'dev', 'ANY', 'ANY', variant);
                devTagList.forEach((devTag) => {
                    definitionTagLookup[devTag] = definitionId;
                });
            })
        }
    }
}

// Get a value from the config file or a similarly named env var
function getConfig(property, defaultVal) {
    defaultVal = defaultVal || null;
    // Generate env var name from property - camelCase to CAMEL_CASE
    const envVar = property.split('').reduce((prev, next) => {
        if (next >= 'A' && next <= 'Z') {
            return prev + '_' + next;
        } else {
            return prev + next.toLocaleUpperCase();
        }
    }, '');

    return process.env[envVar] || config[property] || defaultVal;
}


// Convert a release string (v1.0.0) or branch (master) into a version. If a definitionId and 
// release string is passed in, use the version specified in defintion-build.json if one exists.
function getVersionFromRelease(release, definitionId) {
    definitionId = definitionId || 'NOT SPECIFIED';

    // Already is a version
    if (!isNaN(parseInt(release.charAt(0)))) {
        return config.definitionVersions[definitionId] || release;
    }

    // Is a release string
    if (release.charAt(0) === 'v' && !isNaN(parseInt(release.charAt(1)))) {
        return config.definitionVersions[definitionId] || release.substr(1);
    }

    // Is a branch
    return 'dev';
}

// Look up distro and fallback to debian if not specified
function getLinuxDistroForDefinition(definitionId) {
    return config.definitionBuildSettings[definitionId].rootDistro || 'debian';
}

// Generate 'latest' flavor of a given definition's tag
function getLatestTag(definitionId, registry, registryPath) {
    if (typeof config.definitionBuildSettings[definitionId] === 'undefined') {
        return null;
    }
    return config.definitionBuildSettings[definitionId].tags.reduce((list, tag) => {
        list.push(`${registry}/${registryPath}/${tag.replace(/:.+/, ':latest')}`);
        return list;
    }, []);

}

function getVariants(definitionId) {
    return config.definitionBuildSettings[definitionId].variants;
}

// Create all the needed variants of the specified version identifier for a given definition
function getTagsForVersion(definitionId, version, registry, registryPath, variant) {
    if (typeof config.definitionBuildSettings[definitionId] === 'undefined') {
        return null;
    }
    // Use the first variant if none passed in, unless there isn't one
    if (!variant) {
        const variants = getVariants(definitionId);
        variant = variants ? variants[0] : 'NOVARIANT';
    }
    return config.definitionBuildSettings[definitionId].tags.reduce((list, tag) => {
        // One of the tags that needs to be supported is one where there is no version, but there
        // are other attributes. For example, python:3 in addition to python:0.35.0-3. So, a version
        // of '' is allowed. However, there are also instances that are just the version, so in 
        // these cases latest would be used instead. However, latest is passed in separately.
        let baseTag = tag.replace('${VERSION}', version)
            .replace(':-', ':')
            .replace('${VARIANT}', variant || 'NOVARIANT')
            .replace('-NOVARIANT', '');
        if (baseTag.charAt(baseTag.length - 1) !== ':') {
            list.push(`${registry}/${registryPath}/${baseTag}`);
        }
        return list;
    }, []);
}

// Generate complete list of tags for a given definition
function getTagList(definitionId, release, updateLatest, registry, registryPath, variant) {
    const version = getVersionFromRelease(release, definitionId);
    if (version === 'dev') {
        return getTagsForVersion(definitionId, 'dev', registry, registryPath, variant);
    }

    const versionParts = version.split('.');
    if (versionParts.length !== 3) {
        throw (`Invalid version format in ${version}.`);
    }

    const versionList = updateLatest ? [
        version,
        `${versionParts[0]}.${versionParts[1]}`,
        `${versionParts[0]}`,
        '' // This is the equivalent of latest for qualified tags- e.g. python:3 instead of python:0.35.0-3
    ] : [
            version,
            `${versionParts[0]}.${versionParts[1]}`
        ];

    // If this variant should actually be the latest tag, use it
    let tagList = (updateLatest && config.definitionBuildSettings[definitionId].latest) ? getLatestTag(definitionId, registry, registryPath) : [];
    versionList.forEach((tagVersion) => {
        tagList = tagList.concat(getTagsForVersion(definitionId, tagVersion, registry, registryPath, variant));
    });

    return tagList;
}

// Walk the image build config and paginate and sort list so parents build before (and with) children
function getSortedDefinitionBuildList(page, pageTotal) {

    // Bucket definitions by parent
    const parentBuckets = {}
    const noParentList = [];
    let total = 0;
    for (let definitionId in config.definitionBuildSettings) {
        if (typeof config.definitionBuildSettings[definitionId] === 'object') {
            const parentId = config.definitionBuildSettings[definitionId].parent;
            // TODO: Handle parents that have parents
            if (typeof parentId !== 'undefined') {
                parentBuckets[parentId] = parentBuckets[parentId] || [parentId];
                parentBuckets[parentId].push(definitionId);
            } else {
                noParentList.push(definitionId);
            }
            total++;
        }
    }
    // Remove parents from no parent list - they are in their buckets already
    for (let parentId in parentBuckets) {
        if (typeof parentId !== 'undefined') {
            noParentList.splice(noParentList.indexOf(parentId), 1);
        }
    }

    // Create pages and distribute entries with no parents
    const pageSize = Math.ceil(total / pageTotal);
    const allPages = [];
    for (let bucketId in parentBuckets) {
        let bucket = parentBuckets[bucketId];
        if (typeof bucket === 'object') {
            if (noParentList.length > 0 && bucket.length < pageSize) {
                const toConcat = noParentList.splice(0, pageSize - bucket.length);
                bucket = bucket.concat(toConcat);
            }
            allPages.push(bucket);
        }
    }
    if (noParentList.length > 0) {
        allPages.push(noParentList);
    }

    if (allPages.length > pageTotal) {
        // If too many pages, add extra pages to last one
        for (let i = pageTotal; i < allPages.length; i++) {
            allPages[allPages.length - 2] = allPages[allPages.length - 2].concat(allPages[i]);
            allPages[i] = [];
        }
    } else if (allPages.length < pageTotal) {
        // If too few, add some empty pages
        for (let i = allPages.length; i < pageTotal; i++) {
            allPages.push([]);
        }
    }

    console.log(`(*) Builds paginated as follows: ${JSON.stringify(allPages, null, 4)}\n(*) Processing page ${page} of ${pageTotal}.\n`);

    return allPages[page - 1];
}

// Get parent tag for a given child definition
function getParentTagForVersion(definitionId, version, registry, registryPath, variant) {
    const parentId = config.definitionBuildSettings[definitionId].parent;
    return parentId ? getTagsForVersion(parentId, version, registry, registryPath, variant)[0] : null;
}

function getUpdatedTag(currentTag, currentRegistry, currentRegistryPath, updatedVersion, updatedRegistry, updatedRegistryPath, variant) {
    updatedRegistry = updatedRegistry || currentRegistry;
    updatedRegistryPath = updatedRegistryPath || currentRegistryPath;
    const captureGroups = new RegExp(`${currentRegistry}/${currentRegistryPath}/(.+:.+)`).exec(currentTag);
    const updatedTags = getTagsForVersion(definitionTagLookup[`ANY/ANY/${captureGroups[1]}`], updatedVersion, updatedRegistry, updatedRegistryPath, variant);
    if (updatedTags && updatedTags.length > 0) {
        console.log(`      Updating ${currentTag}\n      to ${updatedTags[0]}`);
        return updatedTags[0];
    }
    // In the case where this is already a tag with a version number in it,
    // we won't get an updated tag returned, so we'll just reuse the current tag.
    return currentTag;
}

// Return just the major version of a release number
function majorFromRelease(release, definitionId) {
    const version = getVersionFromRelease(release, definitionId);

    if (version === 'dev') {
        return 'dev';
    }

    const versionParts = version.split('.');
    return versionParts[0];
}

// Return an object from a map based on the linux distro for the definition
function objectByDefinitionLinuxDistro(definitionId, objectsByDistro) {
    const distro = getLinuxDistroForDefinition(definitionId);
    const obj = objectsByDistro[distro];
    return obj;
}

function getDefinitionDependencies(definitionId) {
    return config.definitionDependencies[definitionId];
}

function getAllDependencies() {
    return config.definitionDependencies;
}

async function getStagingFolder(release) {
    if (!stagingFolders[release]) {
        const stagingFolder = path.join(os.tmpdir(), 'vscode-dev-containers', release);
        console.log(`(*) Copying files to ${stagingFolder}\n`);
        await asyncUtils.rimraf(stagingFolder); // Clean out folder if it exists
        await asyncUtils.mkdirp(stagingFolder); // Create the folder
        await asyncUtils.copyFiles(
            path.resolve(__dirname, '..', '..', '..'),
            getConfig('filesToStage'),
            stagingFolder);

        stagingFolders[release] = stagingFolder;
    }
    return stagingFolders[release];
}

module.exports = {
    loadConfig: loadConfig,
    getTagList: getTagList,
    getVariants: getVariants,
    getSortedDefinitionBuildList: getSortedDefinitionBuildList,
    getParentTagForVersion: getParentTagForVersion,
    getUpdatedTag: getUpdatedTag,
    majorFromRelease: majorFromRelease,
    objectByDefinitionLinuxDistro: objectByDefinitionLinuxDistro,
    getDefinitionDependencies: getDefinitionDependencies,
    getAllDependencies: getAllDependencies,
    getStagingFolder: getStagingFolder,
    getLinuxDistroForDefinition: getLinuxDistroForDefinition,
    getVersionFromRelease: getVersionFromRelease,
    getTagsForVersion: getTagsForVersion,
    getConfig: getConfig
};
