/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as fs from 'fs';
import * as cp from 'child_process';
import * as path from 'path';
import * as https from 'https';
import * as Docker from 'dockerode';
import * as config from '../config/testConfig.json';

let logLevel: string;

export function getConfig(property: string, defaultVal: any = undefined) {
	// Generate env var name from property - pascalCase to PASCAL_CASE
	const envVar = property.split('').reduce((prev: string, next: string) => {
		if (next >= 'A' && next <= 'Z') {
			return prev + '_' + next;
		} else {
			return prev + next.toLocaleUpperCase();
		}
	}, '');

	return process.env[envVar] || (<any>config)[property] || defaultVal;
}

export async function getStringFromUri(uri: string) {
	return new Promise<string>((resolve, reject) => {
		https.get(uri, (res) => {
			let result = '';
			res.on('data', (chunk)=> { result += chunk.toString(); })
			res.on('close',() => { resolve(result); });
			res.on('error', (err) => { reject(err); });
		});	
	})
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


export function findMountDestination(containerInfo: Docker.ContainerInspectInfo, sourceDir: string, vscodeDevConPath: string) {
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

export interface SpawnResult {
	code: number;
	signal: string;
	error: Error | null;
	output: string;
	stdout: string;
	stderr: string;
}

export function spawn(command: string, args: string[], options: cp.SpawnOptions = {}) {
	return new Promise<SpawnResult>((resolve, reject) => {
		if (getLogLevel() === 'trace') {
			options.stdio = 'inherit';
		}
		const result: SpawnResult = {
			code: 1,
			signal: '',
			error: null,
			output: '',
			stdout: '',
			stderr: ''
		}
		const process = cp.spawn(command, args, options);
		if (process.stdout) {
			process.stdout.on('data', (chunk: any)=> {
				result.output += chunk.toString();
				result.stdout += chunk.toString();
			});	
		}
		if (process.stderr) {
			process.stderr.on('data', (chunk: any)=> {
				result.output += chunk.toString();
				result.stderr += chunk.toString();
			});	
		}
		process.on('close', (code: number, signal: string) => {
			result.code = code;
			result.signal = signal;
			resolve(result);
		});
		process.on('error', (err: Error) => {
			result.error = err;
			reject(result);
		});
	});
}

