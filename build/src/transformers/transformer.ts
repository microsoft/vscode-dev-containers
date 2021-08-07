import { Lookup } from '../domain/common';
import { CgComponent } from '../domain/definition';
import { ExtractedInfo } from '../utils/image-info-extractor';

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

export abstract class InfoTransformer {
    abstract image: ((info: ImageInfo) => any) | null;
    abstract distro: ((info: DistroInfo) => any) | null;
    abstract linux: ((info: PackageInfo) => any) | null;
    abstract npm: ((info: PackageInfo) => any) | null;
    abstract pip: ((info: PackageInfo) => any) | null;
    abstract pipx: ((info: PackageInfo) => any) | null;
    abstract gem: ((info: PackageInfo) => any) | null;
    abstract cargo: ((info: PackageInfo) => any) | null;
    abstract go: ((info: PackageInfo) => any) | null;
    abstract git: ((info: PackageInfo) => any) | null;
    abstract other: ((info: PackageInfo) => any) | null;
    abstract languages:((info: PackageInfo) => any) | null;
    abstract manual: ((info: CgComponent) => any) | null;

    // Return all contents as an object of formatted values
    transform(info: ExtractedInfo): any {
        let transformedInfo = {};
        for (let contentType in info) {
            if(this[contentType]) {
                transformedInfo[contentType] = this.executeTransformation(info[contentType], this[contentType]);
            }
        }    
        return transformedInfo;
    }

    private executeTransformation(info: any, transformerFn: Function) {
        if (!transformerFn || !info) {
            return null;
        }
        if(!Array.isArray(info)) {
            return transformerFn(info);
        }
        return info.reduce((prev, next) => {
            const transformedInfo = transformerFn(next);
            if(transformedInfo) {
                prev.push(transformedInfo);
            }
            return prev;
        }, []);    
    }
}
