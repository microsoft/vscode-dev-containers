/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

import * as fetch from 'isomorphic-fetch';

export default class DaprClient {
    private readonly daprEndpoint: string;

    constructor(daprEndpoint?: string) {
        this.daprEndpoint = daprEndpoint ?? `http://localhost:${process.env.DAPR_HTTP_PORT ?? 3500 }/v1.0`;
    }

    public async getState<T>(store: string, key: string): Promise<T | undefined> {
        const response = await fetch(`${this.daprEndpoint}/state/${store}/${key}`);

        if (!response.ok) {
            throw new Error('Could not get state.');
        } else if (response.status === 204) {
            return undefined;
        }

        const value = await response.text();

        if (!value) {
            return undefined;
        }

        return JSON.parse(value);
    }

    public async setState<T>(store: string, key: string, value: T): Promise<void> {
        const response = await fetch(
            `${this.daprEndpoint}/state/${store}`,
            {
                body: JSON.stringify([{ key, value }]),
                headers: {
                    "Content-Type": "application/json",
                },
                method: 'POST',
            });

        if (!response.ok) {
            throw new Error('Could not set state.');
        }
    }
}
