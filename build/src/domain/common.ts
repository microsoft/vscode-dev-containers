export interface Lookup<T> {
    [key: string]: T
}

export interface CommonParams {
    githubRepo: string;
    release: string;
    registry: string;
    repository: string;
    stubRegistry:string;
    stubRepository: string;
}
