/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as fs from 'fs';
import * as path from 'path';
import * as tv4 from 'tv4';
import * as Docker from 'dockerode';
import { jsonc } from 'jsonc';
import { resolve, getDevContainerConfigPathIn, readDevContainerConfigFile } from 'remote-containers/src/node/configContainer';
import { exec, createTestParams } from 'remote-containers/test/testUtils';
import * as config from '../config/testConfig.json';

let logLevel: string;

// Docker instance used in a few spots
const docker = new Docker();

// Dev Container schema
log('debug', 'Reading JSON schema');
const schema = jsonc.readSync(path.join(__dirname, '..', 'config', 'devContainer.schema.json'));

export function getConfig(property: string, defaultVal: any = undefined) {
	// Generate env var name from property
	const envVar = property.split('').reduce((prev: string, next: string) => {
		if (next >= 'A' && next <= 'Z') {
			return prev + '_' + next;
		} else {
			return prev + next.toLocaleUpperCase();
		}
	}, '');

	return process.env[envVar] || (<any>config)[property] || defaultVal;
}
export function getLogLevel() {
	if (!logLevel) {
		logLevel = getConfig('testLogLevel', 'info');
	}
	return logLevel;
}

export function log(level: string, message: string) {
	let levels: string[] = [];
	switch (getLogLevel()) {
		case 'error': levels = ['error']; break;
		case 'info': levels = ['error', 'info']; break;
		case 'debug': levels = ['error', 'info', 'debug']; break;
		case 'trace': levels = ['error', 'info', 'debug', 'trace']; break;
	}
	if (levels.indexOf(level) >= 0) {
		console.log(message);
	}
}

export function getRootFolderRealPath(type: string) {
	const rootPath = getConfig('devContainerRoot', path.join(__dirname, '..', '..'));
	const expectedDevConPath = path.join(rootPath, type);
	return fs.existsSync(expectedDevConPath) ? fs.realpathSync(expectedDevConPath) : expectedDevConPath;
}

export function getDefinitionListFromPath(definitionsPath: string, configProperty: string, getFn: (path: string) => {} = defaultGetDefnitionListFn) {
	const subsetToTest = getConfig(configProperty);
	if (subsetToTest) {
		if (subsetToTest === 'none') {
			return [];
		}
		if (typeof subsetToTest === 'string') {
			return [subsetToTest];
		} else {
			return subsetToTest;
		}
	} else {
		return getFn(definitionsPath);
	}
}

function defaultGetDefnitionListFn(definitionsPath: string) {
	const definitionList: string[] = [];
	fs.readdirSync(definitionsPath).forEach((dir: string) => {
		if (fs.statSync(path.join(definitionsPath, dir)).isDirectory()) {
			definitionList.push(dir);
		}
	});
	return definitionList;

}

export function validatetDevContainerJson(definitionPath: string) {
	log('debug', `Validating devcontainer.json at ${definitionPath}`);
	const jsonPath = path.join(definitionPath, '.devcontainer', 'devcontainer.json');
	const json = fs.existsSync(jsonPath) ? jsonc.readSync(jsonPath) :
		jsonc.readSync(path.join(definitionPath, '.devcontainer.json'));

	return tv4.validate(json, schema);
}

export async function testContainerResolver(definitionPath: string): Promise<any> {

	log('debug', `Finding and reading devcontainer.json at ${definitionPath}`);
	const configPath = await getDevContainerConfigPathIn(definitionPath);
	const config: any = configPath && await readDevContainerConfigFile(configPath);

	const params = await createTestParams();
	params.getExtensionsToInstall = () => config.extensions;
	params.cwd = definitionPath;
	params.progress = {
		report: (value: any) => { log('trace', value.message); }
	};
	params.output = {
		write: (message) => { log('trace', message); }
	};

	log('debug', 'Running resolver.');
	return await resolve(params, config);
}

export async function execTestScript(devContainer: any, vscodeDevConPath: string = '') {
	const container = await docker.getContainer(devContainer.properties.id);
	const containerInfo = await container.inspect();
	const workingDir = findMountDestination(containerInfo, devContainer.params.cwd, vscodeDevConPath);
	const result = await exec(`docker exec ${containerInfo.Id} /bin/sh -c "cd ${workingDir} && if [ -f test-project/test.sh ]; then chmod +x test-project/test.sh && ./test.sh; else ls -a; fi"`)
	log('trace', result.stdout);
	if (result.error) {
		log('trace', result.error + ': ' + result.stderr);
	}

	return result;
}

function findMountDestination(containerInfo: Docker.ContainerInspectInfo, sourceDir: string, vscodeDevConPath: string) {
	for (let i = 0; i < containerInfo.Mounts.length; i++) {
		const mount = containerInfo.Mounts[i];
		// Handle case where the git directory is mounted
		if (mount.Source === vscodeDevConPath) {
			return path.join(mount.Destination, sourceDir.substr(vscodeDevConPath.length));
		}
		// Handle case where sourceDir is directly mounted
		if (mount.Source === sourceDir) {
			return mount.Destination;
		}
	}
	return null;
}

export async function cleanUp(devContainer: any) {

	log('debug', 'Stopping container');
	devContainer.params.shutdowns.forEach(async (shutdown: (rebuild?: boolean) => {}) => await shutdown(false));

	log('debug', 'Removing container');
	const container = await docker.getContainer(devContainer.properties.id);
	await container.remove({ force: true });

	log('debug', 'Pruning all unused images');
	const result = await exec('docker image prune -a -f');
	log('trace', result.stdout);
	if (result.error) {
		log('trace', result.error + ': ' + result.stderr);
	}

	return result;
}