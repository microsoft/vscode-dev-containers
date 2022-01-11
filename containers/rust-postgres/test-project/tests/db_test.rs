/*--------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

use std::{env, net::TcpStream};
extern crate postgres;
use postgres::{Client, NoTls};

#[test]
fn test_ping_database() -> Result<(), Box<dyn std::error::Error>> {
    let host = env::var("POSTGRES_HOSTNAME")?;
    let _ = TcpStream::connect(format!("{}:5432", host))?;
    println!("Ping database succeed");
    Ok(())
}

#[test]
fn test_connection_query_database() -> Result<(), Box<dyn std::error::Error>> {
    let host = env::var("POSTGRES_HOSTNAME")?;
    let user = env::var("POSTGRES_USER")?;
    let passwd = env::var("POSTGRES_PASSWORD")?;
    let db = env::var("POSTGRES_DB")?;
    let conn_str = format!("postgresql://{}:{}@{}:5432/{}", user, passwd, host, db);

    let mut conn = match Client::connect(&conn_str, NoTls) {
        Ok(conn) => conn,
        Err(err) => {
            return Err(Box::new(std::io::Error::new(
                std::io::ErrorKind::NotConnected,
                format!("Connection failed {}", err),
            )))
        }
    };

    for row in conn.query("select * from pg_database limit 1;", &[])? {
        let val: String = row.get("datname");
        println!("Database name = {}", val);
    }
    Ok(())
}
