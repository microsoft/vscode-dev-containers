/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as path from 'path';
import { assert } from 'chai';
import { validatetDevContainerJson, testContainerResolver, execTestScript, cleanUp, getConfig } from './containerTestUtils';
import { fetchAgentCommit } from 'remote-containers/test/testUtils';


export function describeTest(description: string, rootFolder: string, definitionList: string[]) {

	definitionList.forEach((definition: string) => {
		describe(`${description}: ${definition}`, function () {
			const definitionPath = path.join(rootFolder, definition);
			let devContainer: any;
	
			// Validate devcontainer.json
			it('devcontainer.json should be valid', function () {
				this.slow(5000);
				assert.isTrue(validatetDevContainerJson(definitionPath));
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
				assert.isNull(result.error, result.error + ': ' + result.stderr);
	
				return true;
			});
	
			it('should clean up', async function () {
				this.slow(120000);
				this.timeout(0);
	
				const result = await cleanUp(devContainer);
				assert.isNull(result.error, result.error + ': ' + result.stderr);
	
				return true;
			});
	
			return true;
		});
	});
}

