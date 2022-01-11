/*-------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

#include <iostream>
#include <mariadb/conncpp.hpp>

using namespace std;

int main() 
{
    cout << "Hello, Remote World!" << "\n";
    
    try
    {    
        string databasename = getenv("MARIADB_DATABASE");
        string password = getenv("MARIADB_PASSWORD");
        string username = getenv("MARIADB_USER");
        string hostname = getenv("MARIADB_DATABASE");
        string jointURL = "jdbc:mariadb://" + hostname + "/" + databasename;
        
        // Instantiate Driver
        sql::Driver* driver = sql::mariadb::get_driver_instance();

        cout << "DB Connecting" << "\n";


        // Configure Connection
        sql::SQLString url(jointURL);
        sql::Properties properties({{"user", username}, {"password", password}});

        // Establish Connection
        unique_ptr<sql::Connection> conn(driver->connect(url, properties));

        cout << "DB Executing" << "\n";

        // Create a new Statement
        sql::Statement *stmt;
        // Create resultSet
        sql::ResultSet *res;

        string query = "show databases "
                        "where `database` not in " 
                        "('information_schema', 'performance_schema');";
        
        stmt = conn->createStatement();
        res = stmt->executeQuery(query);
        
        cout << "Cluster has the following user created databases" << "\n";
        
        while(res -> next()) 
        {
            cout << res->getString(1) << endl;
        }

        cout << "DB Success" << "\n";

        delete res;
        delete stmt;
        conn.release();

    } catch(sql::SQLException& e) {
        cerr << "Error Connecting to MariaDB Platform: " << e.what() << endl;
        return 1;
    }
    
    return 0;
}
