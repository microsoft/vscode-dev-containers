/*-------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

#include <iostream>
#include <cassert>
#include <mariadb/conncpp.hpp>

using namespace std;

int main()
{
    cout << "Hello, Remote World!" << endl;

    char *databasename = getenv("MARIADB_DATABASE");
    assert(databasename != NULL);
    char *password = getenv("MARIADB_PASSWORD");
    assert(password != NULL);
    char *username = getenv("MARIADB_USER");
    assert(username != NULL);
    char *hostname = getenv("MARIADB_HOSTNAME");
    assert(hostname != NULL);

    string jointURL = "jdbc:mariadb://" + string(hostname) + "/" + string(databasename);
    // Configure Connection
    sql::SQLString url(jointURL);
    sql::Properties properties({{"user", string(username)},
        {"password", string(password)}});

    // Establish Connection
    cout << "DB Connecting" << endl;

    try
    {
        unique_ptr<sql::Connection> conn(sql::DriverManager::getConnection(url, properties));

        string query = "show databases "
                        "where `database` not in "
                        "('information_schema', 'performance_schema');";
        cout << "DB Executing Query" << endl;
        unique_ptr<sql::Statement> stmnt(conn->createStatement());
        unique_ptr<sql::ResultSet> res(stmnt->executeQuery(query));

        cout << "Listing user created databases" << endl;
        while(res->next())
        {
            cout << res->getString(1) << endl;
        }
        conn->close();
    }
    catch(const sql::SQLException& e)
    {
        cerr << "Error Connecting to MariaDB Platform: " << e.what() << endl;
        return 1;
    }
    
    return 0;
}
