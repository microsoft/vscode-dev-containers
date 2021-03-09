/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as express from 'express';
import DaprClient from './daprClient';

const router = express.Router();

const daprClient = new DaprClient();
const store = 'statestore';

router.use(express.json({ strict: false }));

router.get('/:id', async (req, res) => {
    const balance = await daprClient.getState<number>(store, req.params.id);

    if (balance !== undefined) {
        res.status(200).header('Content-Type', 'application/json').send(JSON.stringify(balance));
    } else {
        res.sendStatus(404);
    }
});

router.post('/:id/deposit', async (req, res) => {
    let balance = await daprClient.getState<number>(store, req.params.id) ?? 0;

    balance += req.body as number;

    await daprClient.setState(store, req.params.id, balance);

    res.status(200).header('Content-Type', 'application/json').send(JSON.stringify(balance));
});

router.post('/:id/withdraw', async (req, res) => {
    let balance = await daprClient.getState<number>(store, req.params.id) ?? 0;

    balance -= req.body as number;

    await daprClient.setState(store, req.params.id, balance);

    res.status(200).header('Content-Type', 'application/json').send(JSON.stringify(balance));
});

export default router;
