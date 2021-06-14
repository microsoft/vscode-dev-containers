export interface Lookup<T> {
    [key: string]: T
}

export interface PackageInfo {
    name: string;
    version: string;
    cgIgnore: boolean;
    markdownIgnore: boolean;
    annotation?: string;
    poolUrl?: string;
    poolKeyUrl?: string;
    path?: string;
    repositoryUrl?: string;
    commitHash?: string;
    downloadUrl?: string;
}

export interface ImageInfo {
    name: string;
    digest: string;
}

export interface DistroInfo extends Lookup<string> {
    prettyName: string;
    name: string;
    versionId: string;
    version: string;
    versionCodename: string;
    id: string;
    idLike?: string;
    homeUrl?: string;
    supportUrl?: string;
    bugReportUrl?: string;
}

export interface Formatter {
    image: ((info: ImageInfo) => any) | null;
    distro: ((info: DistroInfo) => any) | null;
    linux: ((info: PackageInfo) => any) | null;
    npm: ((info: PackageInfo) => any) | null;
    pip: ((info: PackageInfo) => any) | null;
    pipx: ((info: PackageInfo) => any) | null;
    gem: ((info: PackageInfo) => any) | null;
    cargo: ((info: PackageInfo) => any) | null;
    go: ((info: PackageInfo) => any) | null;
    git: ((info: PackageInfo) => any) | null;
    other: ((info: PackageInfo) => any) | null;
    languages:((info: PackageInfo) => any) | null;
    manual: ((info: PackageInfo) => any) | null;
}