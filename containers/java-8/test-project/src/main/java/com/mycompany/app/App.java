/*-------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

package com.mycompany.app;

import static javax.xml.XMLConstants.XML_NS_PREFIX;

public class App 
{
    public static void main( String[] args )
    {
        System.out.println( "Hello Remote World!" );
        System.out.println("The XML namespace prefix is: " + XML_NS_PREFIX);
    }
}
