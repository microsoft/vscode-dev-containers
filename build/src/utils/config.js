/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

const os = require('os');
const path = require('path');
const glob = require('glob');
const asyncUtils = require('./async');
const jsonc = require('jsonc').jsonc;
const config = require('../../config.json');

config.definitionDependencies = config.definitionDependencies || {};
config.definitionBuildSettings = config.definitionBuildSettings || {};
config.definitionVersions = config.definitionVersions || {};
config.definitionVariants = config.definitionVariants || {};

const stagingFolders = {};
const definitionTagLookup = {};
const allDefinitionPaths = {};

// Must be called first
async function loadConfig(repoPath) {
    repoPath = repoPath || path.join(__dirname, '..', '..', '..');
    const definitionBuildConfigFile = getConfig('definitionBuildConfigFile', 'definition-manifest.json');

    // Get list of definition folders
    const containersPath = path.join(repoPath, getConfig('containersPathInRepo', 'containers'));
    const definitions = await asyncUtils.readdir(containersPath, { withFileTypes: true });
    await asyncUtils.forEach(definitions, async (definitionFolder) => {
        if (!definitionFolder.isDirectory()) {
            return;
        }
        const definitionId = definitionFolder.name;
        const definitionPath = path.resolve(path.join(containersPath, definitionId));
        allDefinitionPaths[definitionId] = {
            path: definitionPath,
            relativeToRootPath: path.relative(repoPath, definitionPath)
        }
        // If definition-manifest.json exists, load it
        const manifestPath = path.join(definitionPath, definitionBuildConfigFile);
        if (await asyncUtils.exists(manifestPath)) {
            await loadDefinitionManifest(manifestPath, definitionId);
        }
    });

    // Load repo containers to build
    const repoContainersToBuildPath = path.join(repoPath, getConfig('repoContainersToBuildPath', 'repository-containers/build'));
    const repoContainerManifestFiles = glob.sync(`${repoContainersToBuildPath}/**/${definitionBuildConfigFile}`);
    await asyncUtils.forEach(repoContainerManifestFiles, async (manifestFilePath) => {
        const definitionPath = path.resolve(path.dirname(manifestFilePath));
        const definitionId = path.relative(repoContainersToBuildPath, definitionPath);
        allDefinitionPaths[definitionId] = {
            path: definitionPath,
            relativeToRootPath: path.relative(repoPath, definitionPath)
        }
        await loadDefinitionManifest(manifestFilePath, definitionId);
    });

    // Populate image variants and tag lookup
    for (let definitionId in config.definitionBuildSettings) {
        const buildSettings = config.definitionBuildSettings[definitionId];
        const definitionVariants = config.definitionVariants[definitionId];
        const dependencies = config.definitionDependencies[definitionId];

        // Populate images list for variants for dependency registration
        dependencies.imageVariants = definitionVariants ?
            definitionVariants.map((variant) => dependencies.image.replace('${VARIANT}', variant)) :
            [dependencies.image];

        // Populate definition and variant lookup
        if (buildSettings.tags) {
            // Variants can be used as a VARAINT arg in tags, so support that too. However, these can
            // get overwritten in certain tag configs resulting in bad lookups, so **process them first**.
            const variants = definitionVariants ? ['${VARIANT}', '$VARIANT'].concat(definitionVariants) : [undefined];
            
            variants.forEach((variant) => {
                const blankTagList = getTagsForVersion(definitionId, '', 'ANY', 'ANY', variant);
                blankTagList.forEach((blankTag) => {
                    definitionTagLookup[blankTag] = {
                        id: definitionId,
                        variant: variant
                    };
                });
                const devTagList = getTagsForVersion(definitionId, 'dev', 'ANY', 'ANY', variant);
                devTagList.forEach((devTag) => {
                    definitionTagLookup[devTag] = {
                        id: definitionId,
                        variant: variant
                    }
                });
            })
        }
    }
    config.needsDedicatedPage = config.needsDedicatedPage || [];
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

// Loads definition-manifest.json and adds it to config
async function loadDefinitionManifest(manifestPath, definitionId) {
    const buildJson = await jsonc.read(manifestPath);
    if (buildJson.variants) {
        config.definitionVariants[definitionId] = buildJson.variants;
    }
    if (buildJson.build) {
        config.definitionBuildSettings[definitionId] = buildJson.build;
    }
    if (buildJson.dependencies) {
        config.definitionDependencies[definitionId] = buildJson.dependencies;
    }
    if (buildJson.definitionVersion) {
        config.definitionVersions[definitionId] = buildJson.definitionVersion;
    }
}

// Returns location of the definition based on Id
function getDefinitionPath(definitionId, relative) {
    return relative ? allDefinitionPaths[definitionId].relativeToRootPath : allDefinitionPaths[definitionId].path
}

function getAllDefinitionPaths() {
    return allDefinitionPaths;
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

    // Given there could be multiple registries in the tag list, get all the different latest variations
    return config.definitionBuildSettings[definitionId].tags.reduce((list, tag) => {
        const latest = `${registry}/${registryPath}/${tag.replace(/:.+/, ':latest')}`
        if (list.indexOf(latest) < 0) {
            list.push(latest);
        }
        return list;
    }, []);

}

function getVariants(definitionId) {
    return config.definitionVariants[definitionId] || null;
}

// Create all the needed variants of the specified version identifier for a given definition
function getTagsForVersion(definitionId, version, registry, registryPath, variant) {
    if (typeof config.definitionBuildSettings[definitionId] === 'undefined') {
        return null;
    }

    // If the definition states that only versioned tags are returned and the version is 'dev', 
    // add the definition Id to ensure that we do not incorrectly hijack a tag from another definition.
    if (version === 'dev') {
        version = config.definitionBuildSettings[definitionId].versionedTagsOnly ? `dev-${definitionId.replace(/-/mg,'')}` : 'dev';
    }


    // Use the first variant if none passed in, unless there isn't one
    if (!variant) {
        const variants = getVariants(definitionId);
        variant = variants ? variants[0] : 'NOVARIANT';
    }
    let tags = config.definitionBuildSettings[definitionId].tags;

    // See if there are any variant specific tags that should be added to the output
    const variantTags = config.definitionBuildSettings[definitionId].variantTags;
    // ${VARIANT} or $VARIANT may be passed in as a way to do lookups. Add all in this case.
    if (['${VARIANT}', '$VARIANT'].indexOf(variant) > -1) {
        if (variantTags) {
            for (let variantEntry in variantTags) {
                tags = tags.concat(variantTags[variantEntry] || []);
            }
        }
    } else {
        if (variantTags) {
            tags = tags.concat(variantTags[variant] || []);
        }
    }

    return tags.reduce((list, tag) => {
        // One of the tags that needs to be supported is one where there is no version, but there
        // are other attributes. For example, python:3 in addition to python:0.35.0-3. So, a version
        // of '' is allowed. However, there are also instances that are just the version, so in 
        // these cases latest would be used instead. However, latest is passed in separately.
        let baseTag = tag.replace('${VERSION}', version)
            .replace(':-', ':')
            .replace(/\$\{?VARIANT\}?/, variant || 'NOVARIANT')
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

    // If version is 'dev', there's no need to generate semver tags for the version
    // (e.g. for 1.0.2, we should also tag 1.0 and 1). So just return the tags for 'dev'.
    if (version === 'dev') {
        return getTagsForVersion(definitionId, version, registry, registryPath, variant);
    }

    // If this is a release version, split it out into the three parts of the semver
    const versionParts = version.split('.');
    if (versionParts.length !== 3) {
        throw (`Invalid version format in ${version}.`);
    }
    // Normally, we also want to return a tag without a version number, but for
    // some definitions that exist in the same repository as others, we may
    // only want to return a list of tags with part of the version number in it
    const versionedTagsOnly = config.definitionBuildSettings[definitionId].versionedTagsOnly;
    const versionList = versionedTagsOnly ? [
            version,
            `${versionParts[0]}.${versionParts[1]}`,
            `${versionParts[0]}`
        ] : [
            version,
            `${versionParts[0]}.${versionParts[1]}`,
            `${versionParts[0]}`,
            '' // This is the equivalent of latest for qualified tags- e.g. python:3 instead of python:0.35.0-3
        ];

    const allVariants = getVariants(definitionId);
    const firstVariant = allVariants ? allVariants[0] : variant;
    let tagList = [];

    versionList.forEach((tagVersion) => {
        tagList = tagList.concat(getTagsForVersion(definitionId, tagVersion, registry, registryPath, variant));
    });

    // If this variant should also be used for the the latest tag (it's the left most in the list), add it
    return tagList.concat((updateLatest 
        && config.definitionBuildSettings[definitionId].latest
        && variant === firstVariant)
        ? getLatestTag(definitionId, registry, registryPath)
        : []);
}

// Walk the image build config and paginate and sort list so parents build before (and with) children
function getSortedDefinitionBuildList(page, pageTotal, definitionsToSkip) {
    page = page || 1;
    pageTotal = pageTotal || 1;
    definitionsToSkip = definitionsToSkip || [];

    // Bucket definitions by parent
    const parentBuckets = {};
    const dupeBuckets = [];
    const noParentList = [];
    let total = 0;
    for (let definitionId in config.definitionBuildSettings) {
        // If paged build, ensure this definition should be included
        if (typeof config.definitionBuildSettings[definitionId] === 'object') {
            if (definitionsToSkip.indexOf(definitionId) < 0) {
                let parentId = config.definitionBuildSettings[definitionId].parent;
                if (parentId) {
                    // if multi-parent, merge the buckets
                    if (typeof parentId !== 'string') {
                        parentId = createMultiParentBucket(parentId, parentBuckets, dupeBuckets);
                    }
                    bucketDefinition(definitionId, parentId, parentBuckets);
                } else {
                    noParentList.push(definitionId);
                }
                total++;
            } else {
                console.log(`(*) Skipping ${definitionId}.`)
            }
        }
    }
    // Remove duplicate buckets that are no longer needed
    dupeBuckets.forEach((currentBucketId) => {
        parentBuckets[currentBucketId] = undefined;
    });
    // Remove parents from no parent list - they are in their buckets already
    for (let parentId in parentBuckets) {
        if (parentId) {
            noParentList.splice(noParentList.indexOf(parentId), 1);
        }
    }

    const allPages = [];
    let pageTotalMinusDedicatedPages = pageTotal;
    // Remove items that need their own buckets and add the buckets
    if (config.needsDedicatedPage) {
        // Remove skipped items from list that needs dedicated page
        const filteredNeedsDedicatedPage = config.needsDedicatedPage.reduce((prev, current) => (definitionsToSkip.indexOf(current) < 0 ? prev.concat(current) : prev), []);
        if (pageTotal > filteredNeedsDedicatedPage.length) {
            pageTotalMinusDedicatedPages = pageTotal - filteredNeedsDedicatedPage.length;
            filteredNeedsDedicatedPage.forEach((definitionId) => {
                allPages.push([definitionId]);
                const definitionIndex = noParentList.indexOf(definitionId);
                if (definitionIndex > -1) {
                    noParentList.splice(definitionIndex, 1);
                    total--;
                }
            });
        } else {
            console.log(`(!) Not enough pages to give dedicated pages to ${JSON.stringify(filteredNeedsDedicatedPage, null, 4)}. Adding them to other pages.`);
        }
    }

    // Create pages and distribute entries with no parents
    const pageSize = Math.ceil(total / pageTotalMinusDedicatedPages);
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
        console.log(`(!) Not enough pages to dedicate one page per parent. Adding excess definitions to last page.`);
        for (let i = pageTotal; i < allPages.length; i++) {
            allPages[pageTotal - 1] = allPages[pageTotal - 1].concat(allPages[i]);
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

// Handle multi-parent definitions
function createMultiParentBucket(variantParentMap, parentBuckets, dupeBuckets) {
    // Get parent of first variant
    const parentId = variantParentMap[Object.keys(variantParentMap)[0]];
    const firstParentBucket =  parentBuckets[parentId] || [parentId];
    // Merge other parent buckets into the first parent
    for (let currentVariant in variantParentMap) {
        const currentParentId = variantParentMap[currentVariant];
        if (currentParentId !== parentId) {
            const currentParentBucket = parentBuckets[currentParentId];
            // Merge buckets if not already merged
            if (currentParentBucket && dupeBuckets.indexOf(currentParentId) < 0) {
                currentParentBucket.forEach((current) => firstParentBucket.push(current));
            } else if (firstParentBucket.indexOf(currentParentId)<0) {
                firstParentBucket.push(currentParentId);
            }
            dupeBuckets.push(currentParentId);
            parentBuckets[currentParentId]=firstParentBucket;
        }
    }
    parentBuckets[parentId] = firstParentBucket;
    return parentId;
}

// Add definition to correct parent bucket when sorting
function bucketDefinition(definitionId, parentId, parentBuckets) {
    // Handle parents that have parents
    // TODO: Recursive parents rather than just parents-of-parents
    if (config.definitionBuildSettings[parentId].parent) {
        const oldParentId = parentId;
        parentId = config.definitionBuildSettings[parentId].parent;
        parentBuckets[parentId] = parentBuckets[parentId] || [parentId];
        if (parentBuckets[parentId].indexOf(oldParentId) < 0) {
            parentBuckets[parentId].push(oldParentId);
        }
    }

    // Add to parent bucket
    parentBuckets[parentId] = parentBuckets[parentId] || [parentId];
    if (parentBuckets[parentId].indexOf(definitionId) < 0) {
        parentBuckets[parentId].push(definitionId);
    }
}

// Get parent tag for a given child definition
function getParentTagForVersion(definitionId, version, registry, registryPath, variant) {
    let parentId = config.definitionBuildSettings[definitionId].parent;
    if (parentId) {
        if(typeof parentId !== 'string') {
            // Use variant to figure out correct parent, or return first if no variant
            parentId = variant ? parentId[variant] : parentId[Object.keys(parentId)[0]];
        }
        return getTagsForVersion(parentId, version, registry, registryPath, variant)[0];
    }
    return null;
}

// Takes an existing tag and updates it with a new registry version and optionally a variant
function getUpdatedTag(currentTag, currentRegistry, currentRegistryPath, updatedVersion, updatedRegistry, updatedRegistryPath, variant) {
    updatedRegistry = updatedRegistry || currentRegistry;
    updatedRegistryPath = updatedRegistryPath || currentRegistryPath;

    const definition = getDefinitionFromTag(currentTag, currentRegistry, currentRegistryPath, false);

    // If definition not found, fall back on swapping out more generic logic - e.g. for when a image already has a version tag in it
    if (!definition) {
        const repository = new RegExp(`${currentRegistry}/${currentRegistryPath}/(.+):`).exec(currentTag)[1];
        const updatedTag = currentTag.replace(new RegExp(`${currentRegistry}/${currentRegistryPath}/${repository}:(dev-|${updatedVersion}-)?`), `${updatedRegistry}/${updatedRegistryPath}/${repository}:${updatedVersion}-`);
        console.log(`    Using RegEx to update ${currentTag}\n    to ${updatedTag}`);
        return updatedTag;
    }

    // See if definition found and no variant passed in, see if definition lookup returned a variant match
    if (!variant) {
        variant = definition.variant;
    }

    const updatedTags = getTagsForVersion(definition.id, updatedVersion, updatedRegistry, updatedRegistryPath, variant);
    if (updatedTags && updatedTags.length > 0) {
        console.log(`    Updating ${currentTag}\n    to ${updatedTags[0]}`);
        return updatedTags[0];
    }
    // In the case where this is already a tag with a version number in it,
    // we won't get an updated tag returned, so we'll just reuse the current tag.
    return currentTag;
}

// Lookup definition from a tag
function getDefinitionFromTag(tag, registry, registryPath, matchWithVersionNumber) {
    registry = registry || '.+';
    registryPath = registryPath || '.+';
    const captureGroups = new RegExp(`${registry}/${registryPath}/(.+):(.+)`).exec(tag);
    const repo = captureGroups[1];
    const tagPart = captureGroups[2];
    const definition = definitionTagLookup[`ANY/ANY/${repo}:${tagPart}`];
    if (definition) {
        return definition;
    }

    // If lookup fails, try removing a numeric first part - dev- is already handled
    return definitionTagLookup[`ANY/ANY/${repo}:${tagPart.replace(/^\d+-/,'')}`];
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

function getPoolKeyForPoolUrl(poolUrl) {
    const poolKey = config.poolKeys[poolUrl];
    console.log (`(*) Key for ${poolUrl} is ${poolKey}`);
    return poolKey;
}

function getFallbackPoolUrl(package) {
    const poolUrl = config.poolUrlFallback[package];
    console.log (`(*) Fallback pool URL for ${package} is ${poolUrl}`);
    return poolUrl;
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

function shouldFlattenDefinitionBaseImage(definitionId) {
    return (getConfig('flattenBaseImage', []).indexOf(definitionId) >= 0)
}

module.exports = {
    loadConfig: loadConfig,
    getTagList: getTagList,
    getVariants: getVariants,
    getAllDefinitionPaths: getAllDefinitionPaths,
    getDefinitionFromTag: getDefinitionFromTag,
    getDefinitionPath: getDefinitionPath,
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
    getFallbackPoolUrl: getFallbackPoolUrl,
    getPoolKeyForPoolUrl: getPoolKeyForPoolUrl,
    getConfig: getConfig,
    shouldFlattenDefinitionBaseImage: shouldFlattenDefinitionBaseImage
};
