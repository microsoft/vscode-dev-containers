/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as fs from 'fs';
import * as path from 'path';
import * as tv4 from 'tv4';
import { jsonc } from 'jsonc';
import { assert } from 'chai';
import { getConfig, findMountDestination, log, getStringFromUri, spawn } from './containerTestUtils';
import { createTestParams, fetchAgentCommit } from 'remote-containers/test/testUtils';
import { resolve, getDevContainerConfigPathIn, readDevContainerConfigFile } from 'remote-containers/src/node/configContainer';
import { ResolverResult } from 'remote-containers/src/node/utils';


// Dev Container schema
log('debug', 'Downloading devcontainer.json schema');
const schemaPromise = getStringFromUri(getConfig('devContainerSchemaUri'))
	.then((schemaString: string) => { 
		return jsonc.parse(schemaString); 
	});

// Main test description
export function describeTest(description: string, rootFolder: string, definitionList: string[]) {

	definitionList.forEach((definition: string) => {
		describe(`${description}: ${definition}`, function () {
			const definitionPath = path.join(rootFolder, definition);
			let devContainer: ResolverResult;
	
			// Validate devcontainer.json
			it('devcontainer.json should be valid', async function () {
				this.slow(5000);
				assert.isTrue(validateDevContainerJson(definitionPath, await schemaPromise));
			});
	
			// Some definitions won't build since they are templates, skip them
			if (getConfig('skipDefinitionBuild').indexOf(definition) > -1) {
				return true;
			}
	
			// Build or pull image specified by devcontainer.json
			it('should start', async function () {
				this.slow(120000);
				this.timeout(0);
	
				devContainer = await testContainerResolver(definitionPath);
				assert.equal(await fetchAgentCommit(devContainer.resolvedAuthority), devContainer.params.product.commit);
	
				return true;
			});
	
			it('should execute', async function () {
				this.slow(120000);
				this.timeout(0);
	
				const result = await execTestScript(devContainer, path.resolve(rootFolder, '..'));
				assert.isNull(result.error, result.error ? result.error.toString() : 'Null error');
				assert.equal(result.code, 0, `Exit code ${result.code} w/ signal ${result.signal}.\n ${result.output}`);
				return true;
			});
	
			it('should clean up', async function () {
				this.slow(120000);
				this.timeout(0);
	
				const result = await cleanUpTest(devContainer);
				assert.isNull(result.error, result.error ? result.error.toString() : 'Null error');
				assert.equal(result.code, 0, `Exit code ${result.code} w/ signal ${result.signal}.\n ${result.output}`);
				return true;
			});
	
			return true;
		});
	});
}


export function validateDevContainerJson(definitionPath: string, schema: any) {
	log('debug', `Validating devcontainer.json at ${definitionPath}`);
	const jsonPath = path.join(definitionPath, '.devcontainer', 'devcontainer.json');
	const json = fs.existsSync(jsonPath) ? jsonc.readSync(jsonPath) :
		jsonc.readSync(path.join(definitionPath, '.devcontainer.json'));

	return tv4.validate(json, schema);
}

export async function testContainerResolver(definitionPath: string): Promise<ResolverResult> {

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

export async function execTestScript(devContainer: ResolverResult, vscodeDevConPath: string = '') {
	const container = await devContainer.params.docker.getContainer(devContainer.properties.id);
	const containerInfo = await container.inspect();
	const workingDir = findMountDestination(containerInfo, devContainer.params.cwd, vscodeDevConPath);
	const result = await spawn('docker', ['exec', containerInfo.Id, '/bin/sh', '-c', `cd ${workingDir} && if [ -f test-project/test.sh ]; then cd test-project && chmod +x test.sh && ./test.sh; else ls -a; fi`]);
	return result;
}

export async function cleanUpTest(devContainer: ResolverResult) {

	log('debug', 'Stopping container');
	devContainer.params.shutdowns.forEach(async (shutdown: (rebuild?: boolean) => {}) => await shutdown(false));

	log('debug', 'Removing container');
	const container = await devContainer.params.docker.getContainer(devContainer.properties.id);
	await container.remove({ force: true });

	log('debug', 'Pruning all unused images');
	const result = await spawn('docker', ['image', 'prune', '-a', '-f']);
	return result;
}
