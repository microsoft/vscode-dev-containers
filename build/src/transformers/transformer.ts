import { Lookup } from '../domain/common';
import { CgComponent } from '../domain/definition';
import { ExtractedInfo, DistroInfo, ImageInfo, PackageInfo } from '../utils/image-info-extractor';

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
        let transformedInfo = <ExtractedInfo>{};
        for (let contentType in info) {
            if((<any>this)[contentType]) {
                (<any>transformedInfo)[contentType] = this.executeTransformation((<any>info)[contentType], (<any>this)[contentType]);
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
