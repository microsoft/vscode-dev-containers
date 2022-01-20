/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

use std::{env, net::TcpStream};
extern crate postgres;
use postgres::{Client, NoTls};

fn getenv(name: &str) -> String {
    let val = match env::var(name) {
        Ok(val) => val,
        Err(err) => panic!("Error {} {:?}", name, err),
    };
    assert!(!val.is_empty());
    val
}

#[test]
fn test_ping_database() {
    let host = getenv("POSTGRES_HOSTNAME");
    let port = getenv("POSTGRES_PORT");
    let _ = TcpStream::connect(format!("{}:{}", host, port)).expect("Failed to connect");
    println!("Ping database succeed");
}

#[test]
fn test_connection_query_database() {
    let host = getenv("POSTGRES_HOSTNAME");
    let user = getenv("POSTGRES_USER");
    let passwd = getenv("POSTGRES_PASSWORD");
    let db = getenv("POSTGRES_DB");
    let port = getenv("POSTGRES_PORT");
    let conn_str = format!("postgresql://{}:{}@{}:{}/{}", user, passwd, host, port, db);

    let mut conn = Client::connect(&conn_str, NoTls).expect("Connection failed");

    for row in conn
        .query("select * from pg_database limit 1;", &[])
        .expect("Data expected")
    {
        let val: String = row.get("datname");
        println!("Database name = {}", val);
    }
}
