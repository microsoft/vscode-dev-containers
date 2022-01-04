/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

package com.mycompany.app;

import org.junit.Test;

import junit.framework.AssertionFailedError;

import static org.junit.Assert.*;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class AppTest
{


    public static boolean pingAddress(String ipAddress) throws UnknownHostException, IOException
    {
        InetAddress postgresAddress = InetAddress.getByName(ipAddress);
        System.out.println("Sending Ping Request to " + ipAddress);
        if (postgresAddress.isReachable(5000)){
            System.out.println("Successfully Reached: " + ipAddress);
            return true;
        }
        System.out.println("Could not reach or connect to: " + ipAddress);
        return false;
    }

    public static boolean dbLogin(String ipAddress, String username, String password){
        Connection c = null;
        try {
            Class.forName("org.postgresql.Driver");
            c = DriverManager
               .getConnection("jdbc:postgresql://postgresdb/postgres",
               "postgres", "postgres");
            return true;
         } catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getClass().getName()+": "+e.getMessage());
            return false;
         }
    }

    public static boolean listDatabases(String ipAddress, String username, String password){
        Connection c = null;
        Statement stmt = null;

        try {
            Class.forName("org.postgresql.Driver");
            c = DriverManager
               .getConnection("jdbc:postgresql://postgresdb/postgres",
               "postgres", "postgres");
            c.setAutoCommit(false);
            stmt = c.createStatement();
            ResultSet rs = stmt.executeQuery( "select * from pg_database;" );
            System.out.println("List of databases in this cluster.");
            while (rs.next()){
                String databaseName = rs.getString("datname");
                System.out.printf("Database Name = %s ", databaseName);
                System.out.println();
            }
            return true;
         } catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getClass().getName()+": "+e.getMessage());
            return false;
         }
    }


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
            assertTrue( pingAddress(System.getenv("POSTGRES_IP")) );
        } catch (Exception e) {
            throw new AssertionFailedError("Postgresdb is not routable. Container may be offline. Error: " + e);
        }
    }

    @Test
    public void testLogin()
    {
        try {
            assertTrue( dbLogin(System.getenv("POSTGRES_IP"), System.getenv("POSTGRES_USER"), System.getenv("POSTGRES_PASSWORD")) );
        } catch (Exception e) {
            throw new AssertionFailedError("Unable to login to the Postgres DB. Check credentials. Error: " + e);
        }
    }

    @Test
    public void testSQLCommand()
    {
        try {
            assertTrue( listDatabases(System.getenv("POSTGRES_IP"), System.getenv("POSTGRES_USER"), System.getenv("POSTGRES_PASSWORD")) );
        } catch (Exception e) {
            throw new AssertionFailedError("Unable to get a list of Databases from postgresDB. Error: " + e);
        }
    }
}
