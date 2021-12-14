/*-------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

package com.mycompany.app;

import static javax.xml.XMLConstants.XML_NS_PREFIX;
import java.io.*;
import java.net.*;



public class App 
{
    public static void main( String[] args )
    {
        System.out.println( "Hello Remote World!" );
        System.out.println("The XML namespace prefix is: " + XML_NS_PREFIX);

    }

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
}
