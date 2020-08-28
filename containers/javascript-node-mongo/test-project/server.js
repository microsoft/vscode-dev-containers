/*--------------------------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

'use strict';

const express = require('express');
const MongoClient = require('mongodb').MongoClient;

// Constants
const PORT = 3000;
const MONGO_URL = 'mongodb://localhost:27017';
const DB_NAME = 'test-project';
const HOST = '0.0.0.0';

(async function() {
	// Use connect to mongo server
	const client = new MongoClient(MONGO_URL, { useUnifiedTopology: true });
	await client.connect();
	console.log('Connected successfully to Mongo DB');
	const db = client.db(DB_NAME);
	const testHitsCollection = db.collection('test-hits');

	// App
	const app = express();
	app.get('/', async (req, res) => {
		await testHitsCollection.insertOne({ date: new Date() });
		const count = await testHitsCollection.countDocuments();
		res.send('Hello remote world! ' + count + ' test record(s) found.');
	});

	app.listen(PORT, HOST);
	console.log(`Running on http://${HOST}:${PORT}`);

	// Used for automated testing
	if(process.env.REGRESSION_TESTING === 'true') { process.exit(0); }
})();


