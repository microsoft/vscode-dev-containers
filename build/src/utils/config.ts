import { OtherDependency, Dependencies } from '../domain/definition';
import { Lookup } from '../domain/common';
import { loadDefinitions } from '../domain/definition-factory';
import { jsonc } from 'jsonc';
import * as path from 'path';

export interface GlobalConfig {
    commonDependencies?: Dependencies;
    containerRegistry: string;
    containerRegistryPath: string;
    stubRegistry: string;
    stubRegistryPath: string;
    githubRepoName: string;
    containersPathInRepo: string;
    historyFolderName: string;
    repoContainersToBuildPath: string;
    scriptLibraryPathInRepo: string;
    scriptLibraryFolderNameInDefinition: string;
    historyUrlPrefix: string;
    repositoryUrl: string;
    repositoryPath: string;
    imageLabelPrefix: string;
    definitionBuildConfigFile: string;
    devContainerJsonPreamble: string;
    dockerFilePreamble: string;
    filesToStage: string[];
    needsDedicatedPage?: string[];
    flattenBaseImage?: string[];
    poolKeys: Lookup<string>;
    poolUrlFallback: Lookup<string>;
    otherDependencyDefaultSettings?: Lookup<OtherDependency>;
}

let config: GlobalConfig;

export async function loadConfig(repoPath: string): Promise<GlobalConfig> {
    if (config) {
        console.warn('(!) Config loaded multiple times.')
        return;
    }
    config = await jsonc.read(path.join(__dirname, '..', '..', 'config.json'));
    config.repositoryPath = repoPath || config.repositoryPath;
    await loadDefinitions(config);
    return config;
}

// Get a value from the config file or a similarly named env var
export function getConfig(property: string, defaultVal?: string | {} | []) {
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

export function getPoolKeyForPoolUrl(poolUrl: string) {
    const poolKey = config.poolKeys[poolUrl];
    return poolKey;
}

export function getFallbackPoolUrl(linuxPackage: string) {
    const poolUrl = config.poolUrlFallback[linuxPackage];
    console.log (`(*) Fallback pool URL for ${linuxPackage} is ${poolUrl}`);
    return poolUrl;
}

export function shouldFlattenDefinitionBaseImage(definitionId: string) {
    return (getConfig('flattenBaseImage', []).indexOf(definitionId) >= 0)
}

export function getDefaultDependencies(dependencyType: string) {
    const packageManagerConfig = getConfig('commonDependencies');
    return packageManagerConfig ? packageManagerConfig[dependencyType] : null;
}