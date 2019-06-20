/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import { getDefinitionListFromPath, getRootFolderRealPath } from './containerTestUtils';
import { describeTest } from './containerTestBase';

const rootFolder = getRootFolderRealPath('containers');
const definitionList = getDefinitionListFromPath(rootFolder, 'definitionsToTest');

describeTest('Definition', rootFolder, definitionList);
