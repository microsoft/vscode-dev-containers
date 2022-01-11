/*-------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

package main

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/lib/pq"
)

func checkError(err error) {
	if err != nil {
		panic(err)
	}

}

func main() {
	var host string = os.Getenv("POSTGRES_HOSTNAME")
	var user string = os.Getenv("POSTGRES_USER")
	var password string = os.Getenv("POSTGRES_PASSWORD")
	var dbname string = os.Getenv("POSTGRES_DB")

	psqlconn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable", host, user, password, dbname)

	// Ready the Database connection
	db, err := sql.Open("postgres", psqlconn)
	checkError(err)

	// close database connection after it is no longer used
	defer db.Close()

	// check db
	err = db.Ping()
	checkError(err)

	fmt.Println("Connected!")

	fmt.Println("Sending Query to Database")
	rows, err := db.Query(`select datname from pg_database limit 1;`)
	checkError(err)

	// close the query when no longer needed
	defer rows.Close()

	for rows.Next() {
		var datname string

		err = rows.Scan(&datname)
		checkError(err)

		fmt.Printf("One database in this cluster is: %s \n", datname)
	}
}
