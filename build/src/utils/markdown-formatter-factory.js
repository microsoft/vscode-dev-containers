/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

/* 
Returns: 

* package (optional annotation) version

*/
function nameAndVersionFormatter(packageInfo) {
    if (packageInfo.markdownIgnore) {
        return null;
    }
    const nameMarkdown = packageInfo.downloadUrl ? `[${packageInfo.name}](${packageInfo.downloadUrl})` : `${packageInfo.name}`
    return `| ${nameMarkdown}${packageInfo.annotation ? ' (' + packageInfo.annotation + ')' : ''} | ${packageInfo.version.replace(/\n/g,'<br />')} ${packageInfo.path ? '| ' + packageInfo.path : ''} |`;
}

/* 
Returns:

* [repo name](git repository link) (optional annotation) commit

*/
function gitFormatter(repoInfo) {
    if (repoInfo.markdownIgnore) {
        return null;
    }
    return `| [${repoInfo.name}](${repoInfo.repositoryUrl})${repoInfo.annotation ? ' (' + repoInfo.annotation + ')' : ''} | ${repoInfo.commitHash} ${repoInfo.path ? '| ' + repoInfo.path  : ''} |`;
}

/* 
Returns: 

PRETTY_NAME (ID_LIKE-like distro)

e.g 

Ubuntu 20.04.2 LTS (debian-like distro)

*/
function distroFormatter(distroInfo) {
    if (distroInfo.markdownIgnore) {
        return null;
    }
    return `${distroInfo.prettyName}${distroInfo.idLike ? ' (' + distroInfo.idLike + '-like distro)' : ''}`;
}

/*
Returns: digest (image name)
*/
function imageInfoFormatter(imageInfo) {
    if (imageInfo.markdownIgnore) {
        return null;
    }
    return `${imageInfo.digest} (${imageInfo.name})`;
}

/* Handle CG manifest entries like:
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

Returns: 

* [component name](download URL) version

*/
function componentFormatter(component) {
    if (component.markdownIgnore ||component.MarkdownIgnore ) {
        return null;
    }
    let componentType = component.Component.Type;
    // Handle capitalization differences
    if (!component.Component[componentType]) {
        componentType = componentType[0].toUpperCase() + componentType.substr(1);
    }
    const componentInfo = component.Component[componentType];
    if (componentInfo.DownloadUrl) {
        return `* [${componentInfo.Name}](${component.DownloadUrl}) ${componentInfo.Version}`;
    } 
    return `* ${componentInfo.Name} ${componentInfo.Version}`;
}

function getFormatter() {
    return {
        image: imageInfoFormatter,
        distro: distroFormatter,
        linux: nameAndVersionFormatter,
        npm: nameAndVersionFormatter,
        pip: nameAndVersionFormatter,
        pipx: nameAndVersionFormatter,
        gem: nameAndVersionFormatter,
        cargo: nameAndVersionFormatter,
        go: nameAndVersionFormatter,
        git: gitFormatter,
        other: nameAndVersionFormatter,
        languages: nameAndVersionFormatter,
        manual: componentFormatter

    }
}

module.exports = {
    getFormatter: getFormatter
}