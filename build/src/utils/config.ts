import { OtherDependencyInfoExtractionSettings as OtherDependencyInfoExtractionSettings, DependencyInfoExtractionSettingsGroup as DependencyInfoExtractionSettingsGroup } from '../domain/definition';
import { Lookup } from '../domain/common';
import { loadDefinitions } from '../domain/definition-factory';
import { Definition } from '../domain/definition'
import * as path from 'path';
import * as os from 'os';
import * as asyncUtils from './async'

export interface LinuxPackageInfoExtractorParams {
    namePrefix: string;
    listCommand: string;
    lineRegEx: RegExp;
    getUriCommand: string;
    poolUriMatchRegEx: string;
    downloadUriMatchRegEx: string;
    downloadUriSuffix?: string,
}

// Docker images and native OS libraries need to be registered as "other" while others are scenario dependant
const linuxPackageInfoExtractorParamsByPackageManager: Lookup<LinuxPackageInfoExtractorParams> = {
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
    } as LinuxPackageInfoExtractorParams,
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
    } as LinuxPackageInfoExtractorParams
}

export interface GlobalConfig {
    commonDependencies?: DependencyInfoExtractionSettingsGroup;

    containerRegistry: string;
    containerRegistryPath: string;
    stubRegistry: string;
    stubRegistryPath: string;

    repositoryUrlPrefix: string;
    githubRepo: string;
    historyUrlBranch: string;
    historyFolder: string;
    containersFolder: string;
    repoContainersImageFolder: string;
    scriptLibraryFolder: string;
    scriptLibraryFolderInDefinition: string;
    imageLabelPrefix: string;
    definitionBuildConfigFile: string;

    devContainerJsonPreamble: string;
    dockerFilePreamble: string;

    filesToStage: string[];
    needsDedicatedPage?: string[];
    flattenBaseImage?: string[];
    poolKeys: Lookup<string>;
    poolUrlFallback: Lookup<string>;
    otherDependencyDefaultSettings?: Lookup<OtherDependencyInfoExtractionSettings>;

    rootPath: string;
}


const config: GlobalConfig = require(path.join(__dirname, '..', '..', 'config.json'));
const stagingFolders = new Map<string, string>();

export async function loadConfig(rootPath: string): Promise<GlobalConfig> {
    config.rootPath = rootPath || config.rootPath;
    await loadDefinitions(config);
    return config;
}

// Get a value from the config file or a similarly named env var
export function getConfig(property: string, defaultVal: string | {} | [] | null = null): any {
    // Generate env var name from property - camelCase to CAMEL_CASE
    const envVar = property.split('').reduce((prev, next) => {
        if (next >= 'A' && next <= 'Z') {
            return prev + '_' + next;
        } else {
            return prev + next.toLocaleUpperCase();
        }
    }, '');

    return process.env[envVar] || (<any>config)[property] || defaultVal;
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

export async function getStagingFolder(release: string) {
    if (!stagingFolders.has(release)) {
        const stagingFolder = path.join(os.tmpdir(), 'vscode-dev-containers', release);
        console.log(`(*) Copying files to ${stagingFolder}\n`);
        await asyncUtils.rimraf(stagingFolder); // Clean out folder if it exists
        await asyncUtils.mkdirp(stagingFolder); // Create the folder
        await asyncUtils.copyFiles(
            path.resolve(__dirname, '..', '..', '..'),
            getConfig('filesToStage'),
            stagingFolder);

        stagingFolders.set(release, stagingFolder);
    }
    return stagingFolders.get(release);
}

// Convert a release string (v1.0.0) or branch (main) into a version. If a definitionId and 
// release string is passed in, use the version specified in defintion-manifest.json if one exists.
export function  getVersionForRelease(versionOrRelease: string, definition?: Definition): string {
    // Already is a version
    if (!isNaN(parseInt(versionOrRelease.charAt(0)))) {
        return definition?.definitionVersion || versionOrRelease;
    }
    // Is a release string
    if (versionOrRelease.charAt(0) === 'v' && !isNaN(parseInt(versionOrRelease.charAt(1)))) {
        return definition?.definitionVersion || versionOrRelease.substr(1);
    }
    // Is a branch
    return 'dev';
}

export function getPackageInfoExtractorParams(packageManager: string): LinuxPackageInfoExtractorParams {
    const params = linuxPackageInfoExtractorParamsByPackageManager[packageManager];
    if (!params) {
        throw new Error(`Unsupported package manager: ${packageManager}`);
    }
    return params;
}

// Use distro "ID" from /etc/os-release to determine appropriate package manger
export function getLinuxPackageManagerForDistro(distroId: string): string {
    switch (distroId) {
        case 'apt':
        case 'debian':
        case 'ubuntu': return 'apt';
        case 'apk':
        case 'alpine': return 'apk';
    }
    throw new Error(`Unsupported distro: ${distroId}`);
}

export function getPackageInfoExtractorParamsForDistro(distro: string): LinuxPackageInfoExtractorParams {
    return getPackageInfoExtractorParams(getLinuxPackageManagerForDistro(distro));
}

// Convert SNAKE_CASE to snakeCase ... well, technically camelCase :)
export function snakeCaseToCamelCase(variableName: string) {
    return variableName.split('').reduce((prev: string, next: string) => {
        if (prev.charAt(prev.length - 1) === '_') {
            return prev.substr(0, prev.length - 1) + next.toLocaleUpperCase();
        }
        return prev + next.toLocaleLowerCase();
    }, '');
}
