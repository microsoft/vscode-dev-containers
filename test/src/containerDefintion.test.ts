/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------------------------------------------*/

import * as path from 'path';
import * as assert from 'assert';

import { resolve, getDevContainerConfigPathIn, readDevContainerConfigFile } from 'remote-containers/src/node/configContainer';
import { createTestParams, exec, fetchAgentCommit } from 'remote-containers/test/testUtils';

describe('Container definitions', function () {
	this.timeout(1 * 60 * 1000);

	it('Launches VS Code Server', async () => {

		const params = await createTestParams();
		const config = await loadTestConfig('javascript-node-lts');
		const result = await resolve(params, config);

		assert.equal(await fetchAgentCommit(result.resolvedAuthority), params.product.commit);

		await exec(`docker rm -f ${result.properties.id}`);
	});
});

export async function loadTestConfig(folderName: string) {
	const filePath = await getDevContainerConfigPathIn(path.join(__dirname, '..', '..', 'containers', folderName));
	assert.ok(filePath);
	const config = await readDevContainerConfigFile(filePath!);
	assert.ok(config);
	return config!;
}