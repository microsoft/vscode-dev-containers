/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

 'use strict';

const express = require('express');
const promise = require('bluebird');

// Constants
const PORT = 3000;
const HOST = '0.0.0.0';
const cn = {
	host: 'localhost', // host of db container
	port: 5432, // 5432 is the default;
	database: 'postgres', // database name
	user: 'postgres', // database user name
	password: 'postgres' // database password
};
const initOptions = {
	promiseLib: promise
};

(async function() {
	const pgp = require('pg-promise')(initOptions);
	const db = pgp(cn); // database instance;
	const result = await db.one('SELECT current_database()');
	
	// Create express app
	const app = express();
	app.get('/', async (req, res) => {
		res.send('Hello, remote world! Current database: ' + result.current_database);
	});
	
	app.listen(PORT, HOST);
	console.log(`Running on http://${HOST}:${PORT}`);	

	// Used for automated testing
	if(process.env.REGRESSION_TESTING === 'true') { process.exit(0); }
})();
