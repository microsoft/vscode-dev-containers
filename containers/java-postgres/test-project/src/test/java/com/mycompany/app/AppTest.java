/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

package com.mycompany.app;

import org.junit.Test;

import static org.junit.Assert.*;

import java.net.InetAddress;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class AppTest
{
    private Connection CreateConnection(String host, String username, String password) throws Exception{
        Connection c = null;
        Class.forName("org.postgresql.Driver");
        c = DriverManager
            .getConnection("jdbc:postgresql://" + host + "/postgres",
            username, password);
        return c;
    }
            
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
    public void testIP() throws Exception
    {
        String host = System.getenv("POSTGRES_HOSTNAME");

        InetAddress postgresAddress = InetAddress.getByName(host);
        System.out.println("Sending Ping Request to " + host);
        if (postgresAddress.isReachable(5000)){
            System.out.println("Successfully Reached: " + host);
            return;
        }
        System.out.println("Could not reach or connect to: " + host);
    }

    @Test
    public void testLogin() throws Exception
    {
        String host = System.getenv("POSTGRES_HOSTNAME"), username = System.getenv("POSTGRES_USER"), password = System.getenv("POSTGRES_PASSWORD");

        System.out.println("Logging into postgresql at " + host);
        Connection c = CreateConnection(host, username, password);
        System.out.println("Successfully logged into: " + host);
    }

    @Test
    public void testSQLCommand() throws Exception
    {
        String host = System.getenv("POSTGRES_HOSTNAME"), username = System.getenv("POSTGRES_USER"), password = System.getenv("POSTGRES_PASSWORD");

        Connection c = CreateConnection(host, username, password);
        Statement stmt = null;

        c.setAutoCommit(false);
        stmt = c.createStatement();
        ResultSet rs = stmt.executeQuery( "select * from pg_database limit 1;" );
        System.out.println("Name of 1st database in this cluster.");
        while (rs.next()){
            String databaseName = rs.getString("datname");
            System.out.printf("Database Name = %s ", databaseName);
            System.out.println();
        }
    }
}
