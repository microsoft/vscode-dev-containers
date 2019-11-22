/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

const fs = require('fs');
const https = require('https');
const crypto = require('crypto');
const rimrafCb = require('rimraf');
const mkdirpCb = require('mkdirp');
const copyFilesCb = require('copyfiles');
const spawnCb = require('child_process').spawn;
const config = require('../config.json');

/** Async file, spawn, and cp functions **/

function getConfig(property, defaultVal) {
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

function getVersionFromRelease(release) {
    // Already is a version
    if (!isNaN(parseInt(release.charAt(0)))) {
        return release;
    }

    // Is a release string
    if (release.charAt(0) === 'v' && !isNaN(parseInt(release.charAt(1)))) {
        return release.substr(1);
    }

    // Is a branch
    return 'dev';
}

function getLinuxDistroForDefinition(definitionId) {
    return config.definitionBuildSettings[definitionId].rootDistro || 'debian';
}

function getLatestTag(definitionId, registry, registryPath) {
    if (typeof config.definitionBuildSettings[definitionId] === 'undefined') {
        return null;
    }
    return config.definitionBuildSettings[definitionId].tags.reduce((list, tag) => {
        // One of the tags that needs to be supported is one where there is no version, but there
        // are other attributes. For example, python:3 in addition to python:0.35.0-3. So, a version
        // of '' is allowed. However, there are also instances that are just the version, so in 
        // these cases latest would be used instead. However, latest is passed in separately.
        list.push(`${registry}/${registryPath}/${tag.replace(/:.+/, ':latest')}`);
        return list;
    }, []);

}

function getTagsForVersion(definitionId, version, registry, registryPath) {
    if (typeof config.definitionBuildSettings[definitionId] === 'undefined') {
        return null;
    }
    return config.definitionBuildSettings[definitionId].tags.reduce((list, tag) => {
        // One of the tags that needs to be supported is one where there is no version, but there
        // are other attributes. For example, python:3 in addition to python:0.35.0-3. So, a version
        // of '' is allowed. However, there are also instances that are just the version, so in 
        // these cases latest would be used instead. However, latest is passed in separately.
        const baseTag = tag.replace('${VERSION}', version).replace(':-', ':');
        if (baseTag.charAt(baseTag.length - 1) !== ':') {
            list.push(`${registry}/${registryPath}/${baseTag}`);
        }
        return list;
    }, []);
}

module.exports = {
    spawn: async (command, args, opts) => {
        console.log(`(*) Spawn: ${command}${args.reduce((prev, current)=> `${prev} ${current}`,'')}`);

        opts = opts || { stdio: 'inherit', shell: true };
        return new Promise((resolve, reject) => {
            let result = '';
            let errorOutput = '';
            const proc = spawnCb(command, args, opts);
            proc.on('close', (code, signal) => {
                if (code !== 0) {
                    console.log(result);
                    console.error(errorOutput);
                    reject(`Non-zero exit code: ${code} ${signal || ''}`);
                    return;
                }
                resolve(result);
            });
            if (proc.stdout) {
                proc.stdout.on('data', (chunk) => result += chunk.toString());
            }
            if (proc.stderr) {
                proc.stderr.on('data', (chunk) => result += chunk.toString());
            }
            proc.on('error', (err) => {
                reject(err);
            });
        });
    },

    rename: async (from, to) => {
        return new Promise((resolve, reject) => {
            fs.rename(from, to, (err) => err ? reject(err) : resolve());
        });
    },

    readFile: async (filePath) => {
        return new Promise((resolve, reject) => {
            fs.readFile(filePath, 'utf8', (err, data) => err ? reject(err) : resolve(data.toString()));
        });
    },

    writeFile: async function (filePath, data) {
        return new Promise((resolve, reject) => {
            fs.writeFile(filePath, data, 'utf8', (err) => err ? reject(err) : resolve(filePath));
        });
    },

    mkdirp: async (pathToMake) => {
        return new Promise((resolve, reject) => {
            mkdirpCb(pathToMake, (err, made) => err ? reject(err) : resolve(made));
        });
    },

    rimraf: async (pathToRemove, opts) => {
        opts = opts || {};
        return new Promise((resolve, reject) => {
            rimrafCb(pathToRemove, opts, (err) => err ? reject(err) : resolve(pathToRemove));
        });
    },

    copyFiles: async (source, blobs, target) => {
        return new Promise((resolve, reject) => {
            process.chdir(source);
            copyFilesCb(
                blobs.concat(target),
                { all: true },
                (err) => err ? reject(err) : resolve(target));
        });
    },

    readdir: async (dirPath, opts) => {
        opts = opts || {};
        return new Promise((resolve, reject) => {
            fs.readdir(dirPath, opts, (err, files) => err ? reject(err) : resolve(files));
        });
    },

    exists: function (filePath) {
        return fs.existsSync(filePath);
    },

    getTagList: (definitionId, release, updateLatest, registry, registryPath) => {
        const version = getVersionFromRelease(release);
        if (version === 'dev') {
            return getTagsForVersion(definitionId, 'dev', registry, registryPath);
        }

        const versionParts = version.split('.');
        if (versionParts.length !== 3) {
            throw (`Invalid version format in ${version}.`);
        }

        const versionList = updateLatest ? [
            version,
            `${versionParts[0]}.${versionParts[1]}`,
            `${versionParts[0]}`,
            '' // This is the equivalent of latest for qualified tags- e.g. python:3 instead of python:0.35.0-3
        ] : [
                version,
                `${versionParts[0]}.${versionParts[1]}`
            ];

        // If this variant should actually be the latest tag, use it
        let tagList = (updateLatest && config.definitionBuildSettings[definitionId].latest) ? getLatestTag(definitionId, registry, registryPath) : [];
        versionList.forEach((tagVersion) => {
            tagList = tagList.concat(getTagsForVersion(definitionId, tagVersion, registry, registryPath));
        });

        return tagList;
    },

    getSortedDefinitionBuildList: () => {
        const sortedList = [];
        const settingsCopy = JSON.parse(JSON.stringify(config.definitionBuildSettings));

        for (let definitionId in config.definitionBuildSettings) {
            const add = (defId) => {
                if (typeof settingsCopy[defId] === 'object') {
                    add(settingsCopy[defId].parent);
                    sortedList.push(defId);
                    settingsCopy[defId] = undefined;
                }
            }
            add(definitionId);
        }

        return sortedList;
    },

    getParentTagForVersion: (definitionId, version, registry, registryPath) => {
        const parentId = config.definitionBuildSettings[definitionId].parent;
        return parentId ? getTagsForVersion(parentId, version, registry, registryPath)[0] : null;
    },

    majorMinorFromRelease: (release) => {
        const version = getVersionFromRelease(release);

        if (version === 'dev') {
            return 'dev';
        }

        const versionParts = version.split('.');
        return `${versionParts[0]}.${versionParts[1]}`;
    },

    shaForFile: async (filePath) => {
        return new Promise((resolve, reject) => {
            const fd = fs.createReadStream(filePath);
            const hash = crypto.createHash('sha256');
            hash.setEncoding('hex');
            fd.on('end', function () {
                hash.end();
                resolve(hash.read());
            });
            fd.on('error', (err) => {
                reject(err);
            });
            fd.pipe(hash);
        })
    },

    shaForString: (content) => {
        const hash = crypto.createHash('sha256');
        hash.update(content);
        return hash.digest('hex');
    },

    objectByDefinitionLinuxDistro: (definitionId, objectsByDistro) => {
        const distro = getLinuxDistroForDefinition(definitionId);
        const obj = objectsByDistro[distro];
        return obj;
    },

    getUrlAsString: async (url) => {
        return new Promise((resolve, reject) => {
            let content = '';
            const req = https.get(url, function (res) {
                res.on('data', function (chunk) {
                    content += chunk.toString();
                });
            });
            req.on("error", reject);
            req.on('close', () => resolve(content));
        });
    },

    getLinuxDistroForDefinition: getLinuxDistroForDefinition,

    getVersionFromRelease: getVersionFromRelease,

    getTagsForVersion: getTagsForVersion,

    getConfig: getConfig
};
