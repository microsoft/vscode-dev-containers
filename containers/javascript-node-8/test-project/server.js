/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

'use strict';

const express = require('express');

// Constants
const PORT = 3000;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
	res.send('Hello remote world!\n');
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);

// Used for automated testing
if(process.env.REGRESSION_TESTING === 'true') { process.exit(0); }
