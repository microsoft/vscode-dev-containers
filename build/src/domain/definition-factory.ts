/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as path from 'path';
import * as glob from 'glob';
import { Dirent } from 'fs';
import * as asyncUtils from '../utils/async';
import { GlobalConfig, getConfig } from '../utils/config';
import { Definition, DefinitionVariant } from './definition';

let config: GlobalConfig;
let rootPath = path.join(__dirname, '..', '..', '..');
const definitionBuildMap = new Map<string, Definition>();
const definitionVariantTagMap = new Map<string, DefinitionVariant>();
const allDefinitionsMap = new Map<string, Definition>();

// Must be called first
export async function loadDefinitions(globalConfig: GlobalConfig): Promise<void> {
    config = globalConfig;
    rootPath = config.rootPath;
    const definitionBuildConfigFile = getConfig('definitionBuildConfigFile', 'definition-manifest.json');

    // Get list of definition folders
    const containersPath = path.join(rootPath, getConfig('containersPathInRepo', 'containers'));
    const definitions = await asyncUtils.readdir(containersPath, { withFileTypes: true });
    console.log(`(*) Loading definitions from ${containersPath}:`);
    await asyncUtils.forEach(definitions, async (definitionFolder: Dirent) => {
        // If directory entry is a file (like README.md), skip
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
        console.log(`    - ${definitionId}`);
        const definition = new Definition(definitionId, definitionPath, rootPath);
        await definition.load();
        if(definition.hasManifest) {
            definitionBuildMap.set(definitionId, definition);
        }
        allDefinitionsMap.set(definitionId, definition);
    });

    // Load repo containers to build
    const repoContainersToBuildPath = path.join(rootPath, getConfig('repoContainersToBuildPath', 'repository-containers/build'));
    const repoContainerManifestFiles = glob.sync(`${repoContainersToBuildPath}/**/${definitionBuildConfigFile}`);
    await asyncUtils.forEach(repoContainerManifestFiles, async (manifestFilePath: string) => {
        const definitionPath = path.resolve(path.dirname(manifestFilePath));
        const definitionId = path.relative(repoContainersToBuildPath, definitionPath);
        const definition = new Definition(definitionId, definitionPath, rootPath);
        await definition.load();
        definitionBuildMap.set(definitionId, definition);
        allDefinitionsMap.set(definitionId, definition);
    });

    // Populate associations, tag lookup, and image variants for registrations
    for (let definitionId in definitionBuildMap) {
        const definition = getDefinition(definitionId);
        if (!definition) {
            throw new Error(`Definition ${definitionId} not found!`);
        }

        populateParentAssociations(definition);

        // Populate definition and variant lookup
        if (definition.build?.tags) {
            // Variants can be used as a VARAINT arg in tags, so support that too. However, these can
            // get overwritten in certain tag configs resulting in bad lookups, so **process them first**.
            const variants: (string | undefined)[] = definition.variants ? ['${VARIANT}', '$VARIANT', ...definition.variants] : [undefined];

            variants.forEach((variant: string | undefined) => {
                const blankTagList = definition.getImageTagsForRelease('', 'ANY', 'ANY', variant);
                blankTagList.forEach((blankTag: string) => {
                    definitionVariantTagMap.set(blankTag, {
                        definition: definition,
                        variant: variant
                    });
                });
                const devTagList = definition.getImageTagsForRelease('dev', 'ANY', 'ANY', variant);
                devTagList.forEach((devTag: string) => {
                    definitionVariantTagMap.set(devTag, {
                        definition: definition,
                        variant: variant
                    });
                });
            })
        }
    }
    config.needsDedicatedPage = config.needsDedicatedPage || [];
}

// Processes and associate definitions together
function populateParentAssociations(definition: Definition) {
    if(!definition.build?.parent) {
        return;
    }
    // If single parent for all variants (and possibly a single parentVariant)
    if(typeof definition.build.parent === 'string') {
        if (typeof definition.build.parentVariant !== 'string') {
            throw new Error(`Value of parent is a string, but parentVariant is not.`);
        }
        const parentDefinition = getDefinition(definition.build.parent);
        definition.parentDefinitions.set(undefined, {
            definition: parentDefinition,
            variant: <string | undefined>definition.build.parentVariant
        });
        parentDefinition.childDefinitions.push(definition);
    } else {
        if (typeof definition.build.parentVariant !== 'object') {
            throw new Error(`Value of parent is an object, but parentVariant is not.`);
        }
        for (let variant in definition.build.parent) {
            const parentDefinition = getDefinition(definition.build.parent[variant]);
            let variantValue: string | undefined = undefined;
            if (definition.build.parentVariant) {
                variantValue = definition.build.parentVariant[variant];
            }
            definition.parentDefinitions.set(variant, {
                definition: parentDefinition,
                variant: variantValue
            });
            parentDefinition.childDefinitions.push(definition);
        }    
    }
}

export function getAllDefinitions(includeDefinitionsWithoutManifests: boolean = false): Map<string, Definition> {
    return includeDefinitionsWithoutManifests ? definitionBuildMap : allDefinitionsMap;
}

export function getDefinition(definitionId: string): Definition {
    const definition = definitionBuildMap.get(definitionId);
    if (!definition) {
        throw new Error(`Definition ${definitionId} not found!`);
    }
    return definition;
}

// Takes an existing tag and updates it with a new registry version and optionally a variant
export function getUpdatedImageTag(imageTag: string, currentRegistry: string, currentRepositoryPrefix: string, updatedVersion: string, 
    updatedRegistry: string = currentRegistry, updatedRepositoryPrefix: string = currentRepositoryPrefix, variant? : string): string {

    const definitionVariant = getDefinitionVariantFromImageTag(imageTag, currentRegistry, currentRepositoryPrefix);

    // If definition not found, fall back on swapping out more generic logic - e.g. for when a image already has a version tag in it
    if (!definitionVariant) {
        const captureGroups = new RegExp(`${currentRegistry}/${currentRepositoryPrefix}/(.+):`).exec(imageTag);
        if(!captureGroups || captureGroups.length < 2) {
            throw new Error(`Unable to find image name in ${imageTag}.`);
        }
        const imageName = captureGroups[1];
        const updatedImageTag = imageTag.replace(new RegExp(`${currentRegistry}/${currentRepositoryPrefix}/${imageName}:(dev-|${updatedVersion.replace('.', '\.')}-)?`), `${updatedRegistry}/${updatedRepositoryPrefix}/${imageName}:${updatedVersion}-`);
        console.log(`    Using RegEx to update ${imageTag}\n    to ${updatedImageTag}`);
        return updatedImageTag;
    }

    // See if definition found and no variant passed in, see if definition lookup returned a variant match
    if (!variant) {
        variant = definitionVariant.variant;
    }

    const updatedTags = definitionVariant.definition.getImageTagsForRelease(updatedVersion, updatedRegistry, updatedRepositoryPrefix, variant);
    if (updatedTags && updatedTags.length > 0) {
        console.log(`    Updating ${imageTag}\n    to ${updatedTags[0]}`);
        return updatedTags[0];
    }
    // In the case where this is already a tag with a version number in it,
    // we won't get an updated tag returned, so we'll just reuse the current tag.
    return imageTag;
}

// Lookup definition from a tag
export function getDefinitionVariantFromImageTag(imageTag: string, registry = '.+', repository = '.+'): DefinitionVariant {
    const captureGroups = new RegExp(`${registry}/${repository}/(.+):(.+)`).exec(imageTag);
    if (!captureGroups || captureGroups.length < 3) {
        throw new Error(`Unable to find image name and tag in ${imageTag}`);
    }
    const repo = captureGroups[1];
    const tagPart = captureGroups[2];
    let definitionVariant = definitionVariantTagMap.get(`ANY/ANY/${repo}:${tagPart}`);
    if (definitionVariant) {
        return definitionVariant;
    }

    // If lookup fails, try removing a numeric first part - dev- is already handled
    definitionVariant = definitionVariantTagMap.get(`ANY/ANY/${repo}:${tagPart.replace(/^\d+-/,'')}`);
    if(!definitionVariant) {
        throw new Error(`Unable to find definition from tag ${imageTag}`);
    }
    return definitionVariant;
}

// Walk definition associations, bucket by root parent, then paginate and return the requested page
export function getSortedDefinitionBuildList(page: number = 1, pageTotal: number = 1, definitionIdsToSkip: string[] = []): Definition[] {
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
function findRootParentBucket(definition: Definition, parentBucketMap: Map<Definition, Definition[]>): Definition[] {
    // If this is a parent, add it and its children to lookup
    if(definition.parentDefinitions.size === 0) {
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
    let unifiedBucket: Definition[] | undefined = undefined;
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
    if(!unifiedBucket) {
        throw new Error(`Unable to determine bucket for ${definition.id}`);
    }
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
            needsDedicatedPageDefinitionIds.forEach((definitionId: string) => {
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
