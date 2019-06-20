/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import { getDefinitionListFromPath, getConfig, getLogLevel, log } from './containerTestUtils';
import { describeTest } from './containerTestBase';
import * as fs from 'fs';
import * as path from 'path';
import * as cp from 'child_process';

const rootFolder = getConfig('tryRepoRoot', path.join(__dirname, '..', 'vscode-remote-try-repos'));
if(!fs.existsSync(rootFolder)) {
	fs.mkdirSync(rootFolder);
}
const definitionList = getDefinitionListFromPath(rootFolder, 'tryReposToTest', () => getConfig('tryRepoList'));


definitionList.forEach((definition: string) => {
	const definitionPath = path.join(rootFolder, definition);
	// Verify try repos are on disk and clone them if not.
	if (!fs.existsSync(definitionPath)) {
		log('info', `Cloning ${definition}.`);
		fs.mkdirSync(definitionPath);
		cp.execSync(`git clone https://github.com/Microsoft/${definition} ${definitionPath}`, { 
			stdio: getLogLevel() === 'trace' ? 'inherit' : 'ignore' });
	}	
});

describeTest('Try repo', rootFolder, definitionList);
