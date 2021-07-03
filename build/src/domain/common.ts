export interface Lookup<T> {
    [key: string]: T
}

export interface CommonParams {
    repo: string;
    release: string;
    registry: string;
    repository: string;
    stubRegistry:string;
    stubRepository: string;
}

export interface PackageInfo {
    name: string;
    version: string;
    url?: string;
    path?: string;
    annotation?: string;
    poolUrl?: string;
    poolKeyUrl?: string;
    commitHash?: string;
    cgIgnore?: boolean;
    markdownIgnore?: boolean;
}

export interface ImageInfo {
    name: string;
    digest: string;
    user: string;
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

export interface Component {
    Component: {
        Type: string;
        Linux?: {
            Name: string;
            Version: string;
            Distribution: string;
            Release: string;
            "Pool-URL": string;
            "Key-URL": string;
        },
        Npm?: {
            Name: string;
            Version: string;
        },
        Pip?: {
            Name: string;
            Version: string;
        }
        Git?: {
            Name: string;
            repositoryUrl: string;
            commitHash: string;
        },
        Other?: {
            Name: string;
            Version: string;
            DownloadUrl: string;
        },
        RubyGems?: {
            Name: string;
            Version: string;
        },
        Cargo?: {
            Name: string;
            Version: string;
        },
        Go?: {
            Name: string;
            Version: string;
        }
    }
    markdownIgnore?: boolean;
    cgIgnore?: boolean;
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
    manual: ((info: Component) => any) | null;
}

