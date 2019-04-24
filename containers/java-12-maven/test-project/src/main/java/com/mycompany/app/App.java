/*----------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See LICENSE in the project root for license information.
 *---------------------------------------------------------------------------------------*/

package com.mycompany.app;

public class App 
{
    public static void main( String[] args )
    {
        System.out.println("Hello " + getDay(DAY_OF_WEEK.FRIDAY));
    }

    static String getDay(DAY_OF_WEEK dayOfWeek) {
        return switch (dayOfWeek) {
            case MONDAY, TUESDAY, WEDNESDAY, THRUSDAY, FRIDAY -> "Weekday";
            case SATURDAY, SUNDAY -> "Weekend";
        };
    }

    static enum DAY_OF_WEEK { MONDAY, TUESDAY, WEDNESDAY, THRUSDAY, FRIDAY, SATURDAY, SUNDAY};
}
