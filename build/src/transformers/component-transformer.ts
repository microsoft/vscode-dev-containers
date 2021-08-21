/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import { CgComponent } from '../domain/definition';
import { InfoTransformer } from './transformer'
import { ExtractedInfo, DistroInfo, ImageInfo, PackageInfo  } from '../utils/image-info-extractor'

export interface CgManifestInfo {
    linux: CgComponent[];
    npm: CgComponent[];
    pip: CgComponent[];
    pipx: CgComponent[];
    gem: CgComponent[];
    cargo: CgComponent[];
    go: CgComponent[];
    git: CgComponent[];
    other: CgComponent[];
    languages: CgComponent[];
    manual: CgComponent[];
}

/* Generate "Linux" entry for linux packages. E.g.
{
    "Component": {
    "Type": "linux",
    "Linux": {
        "Name": "yarn",
        "Version": "1.22.5-1",
        "Distribution": "Debian",
        "Release": "10",
        "Pool-URL": "https://dl.yarnpkg.com/debian",
        "Key-URL": "https://dl.yarnpkg.com/debian/pubkey.gpg"
    }
}
 */   
function linuxPackageComponentTransformer(packageInfo: PackageInfo, distroInfo: DistroInfo): CgComponent {
    if (packageInfo.cgIgnore) {
        return null;
    }
    return {
        "Component": {
            "Type": "linux",
            "Linux": {
                "Name": packageInfo.name,
                "Version": packageInfo.version,
                "Distribution": distroInfo.id,
                "Release": distroInfo.versionId,
                "Pool-URL": packageInfo.poolUrl,
                "Key-URL": packageInfo.poolKeyUrl
            }
        }
    }
}


/* Generate "Npm" entries. E.g.
{
    "Component": {
        "Type": "npm",
        "Npm": {
            "Name": "eslint",
            "Version": "7.7.0"
        }
    }
}
*/
function npmComponentTransformer(packageInfo: PackageInfo): CgComponent {
    if (packageInfo.cgIgnore) {
        return null;
    }
    return  {
        "Component": {
            "Type": "npm",
            "Npm": {
                "Name": packageInfo.name,
                "Version": packageInfo.version
            }
        }
    }
}


/* Generate "Pip" entries. E.g.
{
    "Component": {
        "Type": "Pip",
        "Pip": {
            "Name": "pylint",
            "Version": "2.6.0"
        }
    }
}
*/
function pipComponentTransformer(packageInfo: PackageInfo) {
    if (packageInfo.cgIgnore) {
        return null;
    }
    return  {
        "Component": {
            "Type": "Pip",
            "Pip": {
                "Name": packageInfo.name,
                "Version": packageInfo.version
            }
        }
    }
}


/* Generate "Git" entries. E.g.
{
    "Component": {
        "Type": "git",
        "Git": {
            "Name": "Oh My Zsh!",
            "repositoryUrl": "https://github.com/ohmyzsh/ohmyzsh.git",
            "commitHash": "cddac7177abc358f44efb469af43191922273705"
        }
    }
}
*/
function gitComponentTransformer(repositoryInfo: PackageInfo) {
    if (repositoryInfo.cgIgnore) {
        return null;
    }
    return {
        "Component": {
            "Type": "git",
            "Git": {
                "Name": repositoryInfo.name,
                "repositoryUrl": repositoryInfo.url,
                "commitHash": repositoryInfo.commitHash
            }
        }
    }
}

/* Generate "Other" entries. E.g.
{
    "Component": {
        "Type": "other",
        "Other": {
            "Name": "Xdebug",
            "Version": "2.9.6",
            "DownloadUrl": "https://pecl.php.net/get/xdebug-2.9.6.tgz"
        }
    }
}
*/
function otherComponentTransformer(packageInfo: PackageInfo) {
    if (packageInfo.cgIgnore) {
        return null;
    }
    return {
        "Component": {
            "Type": "other",
            "Other": {
                "Name": packageInfo.name,
                "Version": packageInfo.version,
                "DownloadUrl": packageInfo.url
            }
        }
    }   
}

/* Generate "RubyGems" entries. E.g.
{
    "Component": {
        "Type": "RubyGems",
        "RubyGems": {
            "Name": "rake",
            "Version": "13.0.1"
        }
    }
}
*/
function gemComponentTransformer(packageInfo: PackageInfo) {
    if (packageInfo.cgIgnore) {
        return null;
    }
    return {
        "Component": {
            "Type": "RubyGems",
            "RubyGems": {
                "Name": packageInfo.name,
                "Version": packageInfo.version
            }
        }
    } 
}

/* Generate "Cargo" entries. E.g.
{
    "Component": {
        "Type": "cargo",
        "Cargo": {
            "Name": "rustfmt",
            "Version": "1.4.17-stable"
        }
    }
}
*/
function cargoComponentTransformer(packageInfo: PackageInfo) {
    if (packageInfo.cgIgnore) {
        return null;
    }
    return {
        "Component": {
            "Type": "cargo",
            "Cargo": {
                "Name": packageInfo.name,
                "Version": packageInfo.version
            }
        }
    }
}

/* Generate "Go" entries. E.g.
"Component": {
    "Type": "go",
    "Go": {
        "Name": "golang.org/x/tools/gopls",
        "Version": "0.6.4"
    }
}
*/
function goComponentTransformer(packageInfo: PackageInfo) {
    if (packageInfo.cgIgnore) {
        return null;
    }
    return {
        "Component": {
            "Type": "go",
            "Go": {
                "Name": packageInfo.name,
                "Version": packageInfo.version
            }
        }
    }
}

// Remove unused properties like markdownIgnore that only apply to other formatters
function manualComponentTransformer(component: CgComponent) {
    if (component.cgIgnore) {
        return null;
    }
    component.markdownIgnore = undefined;
    return component;       
}


export class ComponentInfoTransformer extends InfoTransformer {
    private distroInfo: any;

    constructor(distroInfo: DistroInfo) {
        super();
        this.distroInfo = distroInfo;
    }

    image =  null;
    distro = null;
    linux = (packageInfo: PackageInfo) => linuxPackageComponentTransformer(packageInfo, this.distroInfo);
    npm = npmComponentTransformer;
    pip = pipComponentTransformer;
    pipx =  pipComponentTransformer;
    gem = gemComponentTransformer;
    cargo = cargoComponentTransformer;
    go = goComponentTransformer;
    git = gitComponentTransformer;
    other = otherComponentTransformer;
    languages = otherComponentTransformer;
    manual = manualComponentTransformer;

    transform(info: ExtractedInfo): CgManifestInfo {
        return <CgManifestInfo>super.transform(info);
    }

}

