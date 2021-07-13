/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as os from 'os';
import * as path from 'path';
import * as glob from 'glob';
import { Dirent } from 'fs';
import * as asyncUtils from '../utils/async';
import { GlobalConfig, getConfig } from '../utils/config';
import { Definition, DefinitionVariant } from './definition';
import { Lookup } from './common';



let config: GlobalConfig;
let repositoryPath = path.join(__dirname, '..', '..', '..');
const stagingFolders: Lookup<string> = {};
const definitionLookup: Lookup<Definition> = {};
const definitionTagLookup: Lookup<DefinitionVariant> = {};
const fullDefinitionListLookup: Lookup<Definition> = {};

// Must be called first
export async function loadDefinitions(globalConfig: GlobalConfig): Promise<void> {
    config = globalConfig;
    repositoryPath = config.repositoryPath;
    const definitionBuildConfigFile = getConfig('definitionBuildConfigFile', 'definition-manifest.json');

    // Get list of definition folders
    const containersPath = path.join(repositoryPath, getConfig('containersPathInRepo', 'containers'));
    const definitions = await asyncUtils.readdir(containersPath, { withFileTypes: true });
    await asyncUtils.forEach(definitions, async (definitionFolder: Dirent) => {
        // If directory entry is a file (like README.md, skip
        if (!definitionFolder.isDirectory()) {
            return;
        }

        const definitionId = definitionFolder.name;
        const definitionPath = path.resolve(path.join(containersPath, definitionId));

        // If a .deprecated file is found, remove the directory from staging and return
        if(await asyncUtils.exists(path.join(definitionPath, '.deprecated'))) {
            // TODO: This accidentally deletes things - move it to package instead
            await asyncUtils.rimraf(definitionPath);
            return;
        }

        // Load definitions and if definition-manifest.json exists, load it
        const definition = new Definition(definitionId, definitionPath, repositoryPath);
        await definition.load();
        if(definition.hasManifest) {
            definitionLookup[definitionId] = definition;
        }
        fullDefinitionListLookup[definitionId] = definition;
    });

    // Load repo containers to build
    const repoContainersToBuildPath = path.join(repositoryPath, getConfig('repoContainersToBuildPath', 'repository-containers/build'));
    const repoContainerManifestFiles = glob.sync(`${repoContainersToBuildPath}/**/${definitionBuildConfigFile}`);
    await asyncUtils.forEach(repoContainerManifestFiles, async (manifestFilePath: string) => {
        const definitionPath = path.resolve(path.dirname(manifestFilePath));
        const definitionId = path.relative(repoContainersToBuildPath, definitionPath);
        const definition = new Definition(definitionId, definitionPath, repoPath);
        await definition.load();
        definitionLookup[definitionId] = definition;
        fullDefinitionListLookup[definitionId] = definition;
    });

    // Populate associations, tag lookup, and image variants for registrations
    for (let definitionId in definitionLookup) {
        const definition = getDefinition(definitionId);
        populateParentAssociations(definition);

        // Populate images list for variants for dependency registration
        definition.dependencies.imageVariants = definition.variants ?
            definition.variants.map((variant) => definition.dependencies.image.replace('${VARIANT}', variant)) :
            [definition.dependencies.image];

        // Populate definition and variant lookup
        if (definition.build.tags) {
            // Variants can be used as a VARAINT arg in tags, so support that too. However, these can
            // get overwritten in certain tag configs resulting in bad lookups, so **process them first**.
            const variants = definition.variants ? ['${VARIANT}', '$VARIANT'].concat(definition.variants) : [undefined];

            variants.forEach((variant) => {
                const blankTagList = definition.getTagsForRelease('', 'ANY', 'ANY', variant);
                blankTagList.forEach((blankTag: string) => {
                    definitionTagLookup[blankTag] = {
                        definition: definition,
                        variant: variant
                    };
                });
                const devTagList = definition.getTagsForRelease('dev', 'ANY', 'ANY', variant);
                devTagList.forEach((devTag) => {
                    definitionTagLookup[devTag] = {
                        definition: definition,
                        variant: variant
                    }
                });
            })
        }
    }
    config.needsDedicatedPage = config.needsDedicatedPage || [];
}

// Processes and associate definitions together
function populateParentAssociations(definition: Definition) {
    if(definition.build.parent) {
        definition.parentDefinitions = definition.parentDefinitions || new Map<string | undefined, DefinitionVariant>();
        let parentLookup: (string | Lookup<string>) = definition.build.parent;
        let parentVariantLookup: (string | Lookup<string>) = definition.build.parentVariant;
        // If single parent for all variants (and possibly a single parentVariant)
        if(typeof parentLookup === 'string') {
            const parentDefinition = getDefinition(parentLookup);
            definition.parentDefinitions.set(undefined, {
                definition: parentDefinition,
                variant: <string | undefined>parentVariantLookup
            });
            parentDefinition.childDefinitions = parentDefinition.childDefinitions || [];
            parentDefinition.childDefinitions.push(definition);
        } else {
            for (let variant in parentLookup) {
                const parentDefinition = getDefinition(parentLookup[variant]);
                definition.parentDefinitions.set(variant, {
                    definition: parentDefinition,
                    variant: parentVariantLookup[variant]
                });
                parentDefinition.childDefinitions = parentDefinition.childDefinitions || [];
                parentDefinition.childDefinitions.push(definition);
            }    
        }
    }
}

// Returns location of the definition based on Id
export function getDefinitionPath(definitionId: string, relative: boolean = false): string {
    return relative ? definitionLookup[definitionId].relativePath : definitionLookup[definitionId].path
}

export function getAllDefinitions(includeDefinitionsWithoutManifests: boolean = false): Lookup<Definition> {
    return includeDefinitionsWithoutManifests ? definitionLookup : fullDefinitionListLookup;
}

export function getDefinition(definitionId: string): Definition {
    return definitionLookup[definitionId];
}

// Convert a release string (v1.0.0) or branch (main) into a version. If a definitionId and 
// release string is passed in, use the version specified in defintion-manifest.json if one exists.
export function getVersionFromRelease(release: string, definitionId?: string): string {
    definitionId = definitionId || 'NOT SPECIFIED';

    // Already is a version
    if (!isNaN(parseInt(release.charAt(0)))) {
        return definitionLookup[definitionId]?.definitionVersion || release;
    }

    // Is a release string
    if (release.charAt(0) === 'v' && !isNaN(parseInt(release.charAt(1)))) {
        return definitionLookup[definitionId]?.definitionVersion || release.substr(1);
    }

    // Is a branch
    return 'dev';
}

// Look up distro and fallback to debian if not specified
export function getLinuxDistroForDefinition(definitionId: string): string {
    return definitionLookup[definitionId].build?.rootDistro || 'debian';
}

// Generate 'latest' flavor of a given definition's tag
export function getLatestTags(definitionId: string, registry: string, repository: string): string[] | null {
    if (typeof definitionLookup[definitionId] === 'undefined') {
        return null;
    }
    return definitionLookup[definitionId].getLatestTags(registry, repository);
}

export function getVariants(definitionId): string[] | null {
    return definitionLookup[definitionId]?.variants || null;
}

// Create all the needed variants of the specified version identifier for a given definition
export function getTagsForVersion(definitionId: string, version: string, registry: string, repository: string, variant?: string) {
    if (typeof definitionLookup[definitionId] === 'undefined') {
        return null;
    }
    return definitionLookup[definitionId].getTagsForRelease(version, registry, repository, variant);
}

// Generate complete list of tags for a given definition.
export function getTagList(definitionId: string, versionOrRelease: string, versionPartHandling: string, registry: string, repository: string, variant?: string) {
    if (typeof definitionLookup[definitionId] === 'undefined') {
        return null;
    }
    return definitionLookup[definitionId].getTagList(versionOrRelease, versionPartHandling, registry, repository, variant);
}

// Get parent tag for a given child definition
export function getParentTagForVersion(definitionId: string, version: string, registry: string, repository: string, variant?: string) {
    if (typeof definitionLookup[definitionId] === 'undefined') {
        return null;
    }
    return definitionLookup[definitionId].getParentTagForRelease(version, registry, repository, variant);

}

// Takes an existing tag and updates it with a new registry version and optionally a variant
export function getUpdatedTag(currentTag: string, currentRegistry: string, currentRepository: string, updatedVersion: string, updatedRegistry: string = currentRegistry, updatedRepository: string = currentRepository, variant? : string): string {

    const definitionVariant = getDefinitionVariantFromTag(currentTag, currentRegistry, currentRepository);

    // If definition not found, fall back on swapping out more generic logic - e.g. for when a image already has a version tag in it
    if (!definitionVariant) {
        const repository = new RegExp(`${currentRegistry}/${currentRepository}/(.+):`).exec(currentTag)[1];
        const updatedTag = currentTag.replace(new RegExp(`${currentRegistry}/${currentRepository}/${repository}:(dev-|${updatedVersion}-)?`), `${updatedRegistry}/${updatedRepository}/${repository}:${updatedVersion}-`);
        console.log(`    Using RegEx to update ${currentTag}\n    to ${updatedTag}`);
        return updatedTag;
    }

    // See if definition found and no variant passed in, see if definition lookup returned a variant match
    if (!variant) {
        variant = definitionVariant.variant;
    }

    const updatedTags = definitionVariant.definition.getTagsForRelease( updatedVersion, updatedRegistry, updatedRepository, variant);
    if (updatedTags && updatedTags.length > 0) {
        console.log(`    Updating ${currentTag}\n    to ${updatedTags[0]}`);
        return updatedTags[0];
    }
    // In the case where this is already a tag with a version number in it,
    // we won't get an updated tag returned, so we'll just reuse the current tag.
    return currentTag;
}

// Lookup definition from a tag
export function getDefinitionVariantFromTag(tag, registry = '.+', repository = '.+'): DefinitionVariant {
    const captureGroups = new RegExp(`${registry}/${repository}/(.+):(.+)`).exec(tag);
    const repo = captureGroups[1];
    const tagPart = captureGroups[2];
    const definitionVariant = definitionTagLookup[`ANY/ANY/${repo}:${tagPart}`];
    if (definitionVariant) {
        return definitionVariant;
    }

    // If lookup fails, try removing a numeric first part - dev- is already handled
    return definitionTagLookup[`ANY/ANY/${repo}:${tagPart.replace(/^\d+-/,'')}`];
}

// Return just the major version of a release number
export function majorFromRelease(release: string, definitionId?: string): string {
    const version = getVersionFromRelease(release, definitionId);

    if (version === 'dev') {
        return 'dev';
    }

    const versionParts = version.split('.');
    return versionParts[0];
}

// Return an object from a map based on the linux distro for the definition
export function objectByDefinitionLinuxDistro(definitionId: string, objectsByDistro = {}) {
    const distro = getLinuxDistroForDefinition(definitionId);
    const obj = objectsByDistro[distro];
    return obj;
}

export function getDefinitionDependencies(definitionId: string) {
    return definitionLookup[definitionId].dependencies;
}

export async function getStagingFolder(release: string) {
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

// Walk definition associations, bucket by root parent, then paginate and return the requested page
export function getSortedDefinitionBuildList(page: number = 1, pageTotal: number = 1, definitionIdsToSkip: string[] = []) {
    // Bucket definitions by parent
    const parentBucketMap = new Map<Definition, Definition[]>();
    for (let definitionId in getAllDefinitions()) {
        if(definitionIdsToSkip.indexOf(definitionId) < 0) {
            const definition = getDefinition(definitionId);
            const bucket = findRootParentBucket(definition, parentBucketMap);
            // If definition is a parent, it might be in the list already, otherwise add
            if(bucket.indexOf(definition) < 0) {
                bucket.push(definition);
            }
        }
    }
    const buckets: Definition[][] = [];
    parentBucketMap.forEach((bucket) => {
        if(buckets.indexOf(bucket) < 0) {
            buckets.push(bucket);
        }
    });
    return getPageFromBuckets(buckets, page, pageTotal, definitionIdsToSkip);
}

// Recursively find parent bucket (and create one if it doesn't exist)
function findRootParentBucket(definition: Definition, parentBucketMap: Map<Definition, Definition[]>) {
    // If this is a parent, add it and its children to lookup
    if(!definition.parentDefinitions) {
        let bucket = parentBucketMap.get(definition);
        if (!bucket) {
            bucket =  [definition];
            parentBucketMap.set(definition, bucket);
        } 
        return bucket;
    }
    // If has parents (can be more than one), get all root buckets
    const definitionParentBuckets = new Map<Definition, Definition[]>();
    definition.parentDefinitions.forEach((parentDefinition) => {
        definitionParentBuckets.set(parentDefinition.definition, findRootParentBucket(parentDefinition.definition, parentBucketMap));
    });
    // Merge parent buckets if needed
    let unifiedBucket: Definition[];
    definitionParentBuckets.forEach((bucket, parentDefinition) => {
        if(!unifiedBucket) {
            unifiedBucket = bucket;
        } else {
            // If not the same bucket, merge them
            if(bucket != unifiedBucket) {
                unifiedBucket.push(...bucket);
                parentBucketMap.set(parentDefinition, unifiedBucket);    
            }
        }
    });
    return unifiedBucket;
}

// Take buckets and merge them into the specified number of pages, then return the requested page
function getPageFromBuckets(buckets: Definition[][], page: number, pageTotal: number, definitionsIdsToSkip: string[]): Definition[] {
    // Move all the buckets with just one definition into one big bucket
    const noRelativesBucket: Definition[] = [];
    buckets.forEach((bucket: Definition[], index) => {
        if(bucket.length === 1) {
            noRelativesBucket.push(bucket[0]);
            buckets.splice(index, 1);
        }
    });

    // Figure out total definitions not skipped
    let total = buckets.reduce((prev, bucket) =>prev + bucket.length, 0);
 
    const allPages = [];
    let pageTotalMinusDedicatedPages = pageTotal;
    // Remove items that need their own buckets and add the buckets
    let needsDedicatedPageDefinitionIds = getConfig('needsDedicatedPage', null);
    if (needsDedicatedPageDefinitionIds) {
        // Remove skipped items from list that needs dedicated page
        needsDedicatedPageDefinitionIds = needsDedicatedPageDefinitionIds.reduce((prev: string[], definitionId: string) => (definitionsIdsToSkip.indexOf(definitionId) < 0 ? prev.concat(definitionId) : prev), []);
        if (pageTotal > needsDedicatedPageDefinitionIds.length) {
            pageTotalMinusDedicatedPages = pageTotal - needsDedicatedPageDefinitionIds.length;
            needsDedicatedPageDefinitionIds.forEach((definitionId) => {
                const definition = getDefinition(definitionId);
                allPages.push([definition]);
                const definitionIndex = noRelativesBucket.indexOf(definition);
                if (definitionIndex > -1) {
                    noRelativesBucket.splice(definitionIndex, 1);
                    total--;
                }
            });
        } else {
            console.log(`(!) Not enough pages to give dedicated pages to ${JSON.stringify(needsDedicatedPageDefinitionIds, null, 4)}. Adding them to other pages.`);
        }
    }

    // Create pages and distribute entries with no relatives
    const pageSize = Math.ceil(total / pageTotalMinusDedicatedPages);
    buckets.forEach((bucket) => {
        if (noRelativesBucket.length > 0 && bucket.length < pageSize) {
            const toConcat = noRelativesBucket.splice(0, pageSize - bucket.length);
            bucket.push(...toConcat);
        }
        allPages.push(bucket);
    });
    // Add the remaining into a final bucket
    if (noRelativesBucket.length > 0) {
        allPages.push(noRelativesBucket);
    }

    // If too many pages, add extra pages into last page
    if (allPages.length > pageTotal) {
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

    // Return requested page
    return allPages[page - 1];
}

// Walk the image build config and paginate and sort list so parents build before (and with) children
export function getSortedDefinitionBuildListOld(page: number = 1, pageTotal: number = 1, definitionsToSkip: string[] = []) {
    // Bucket definitions by parent
    const parentBuckets: Lookup<string[]> = {};
    const dupeBuckets = [];
    const noParentList = [];
    let total = 0;
    for (let definitionId in definitionLookup) {
        const definitionBuildSettings = definitionLookup[definitionId]?.build;
        // If paged build, ensure this definition should be included
        if (typeof definitionBuildSettings === 'object') {
            if (definitionsToSkip.indexOf(definitionId) < 0) {
                let parent = definitionBuildSettings.parent;
                if (parent) {
                    // if multi-parent, merge the buckets
                    if (typeof parent !== 'string') {
                        parent = createMultiParentBucket(parent, parentBuckets, dupeBuckets);
                    }
                    bucketDefinition(definitionId, parent, parentBuckets);
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
        allPages.splice(pageTotal)
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
function createMultiParentBucket(variantParentObject: Lookup<string>, parentBuckets: Lookup<string[]>, dupeBuckets: string[]) {
    // Get parent of first variant
    const parentId = variantParentObject[Object.keys(variantParentObject)[0]];
    const firstParentBucket =  parentBuckets[parentId] || [parentId];
    // Merge other parent buckets into the first parent
    for (let currentVariant in variantParentObject) {
        const currentParentId = variantParentObject[currentVariant];
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
function bucketDefinition(definitionId: string, parentId: string, parentBuckets: Lookup<string[]>) {
    // Handle parents that have parents
    // TODO: Recursive parents rather than just parents-of-parents
    if (definitionLookup[parentId].build.parent) {
        const oldParentId = parentId;
        parentId = <string>definitionLookup[parentId].build.parent;
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
