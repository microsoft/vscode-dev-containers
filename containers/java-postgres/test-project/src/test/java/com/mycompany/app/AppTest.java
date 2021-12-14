/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

package com.mycompany.app;

import org.junit.Test;

import junit.framework.AssertionFailedError;

import static org.junit.Assert.*;

import java.io.IOException;
import java.net.UnknownHostException;

public class AppTest
{
    App newApp = new App();
    public AppTest() {
    }

    @Test
    public void testApp()
    {
        assertTrue( true );
    }

    @Test
    public void testMore()
    {
        assertTrue( true );
    }

    @Test
    public void testIP()
    {
        try {
            assertTrue( App.pingAddress("postgresdb") );
        } catch (Exception e) {
            throw new AssertionFailedError("Could not reach PostgresDB. Error: " + e);
        }
    }
}
