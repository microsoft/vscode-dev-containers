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

var result; // stores the connection result

const initOptions = {
    promiseLib: promise // overriding the default (ES6 Promise);
};
const pgp = require('pg-promise')(initOptions);



// Database connection details;
const cn = {
    host: 'db', // host of db container
    port: 5432, // 5432 is the default;
    database: 'data', // database name
    user: 'user', // database user name
    password: 'pass' // database password
};

const db = pgp(cn); // database instance;

db.one(' SELECT current_database();')
    .then(
        result = "Successfully connected to database."
    )
    .catch(error => {
        result = "Failed: " + error
    })

// creating an express app
	const app = express();
	app.get('/', async (req, res) => {
		res.send('Hello, remote world: ' + result);
	});
	app.listen(PORT, HOST);
	console.log(`Running on http://${HOST}:${PORT}`);

