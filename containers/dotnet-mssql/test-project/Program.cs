/*-------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;

namespace aspnetapp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            string databaseNames = "";
            SqlConnectionStringBuilder connectionBuilder = new SqlConnectionStringBuilder();

            connectionBuilder.DataSource = "localhost,1433"; 
            connectionBuilder.UserID = "sa";            
            connectionBuilder.Password = "P@ssw0rd"; 
            using (SqlConnection containerConnection = new SqlConnection(connectionBuilder.ConnectionString)) {
                containerConnection.Open();
                string tsql = "SELECT [NAME] AS DBNAME FROM SYS.DATABASES";

                using (SqlCommand tsqlCommand = new SqlCommand(tsql, containerConnection)) {
                    using (SqlDataReader reader = tsqlCommand.ExecuteReader()) {
                        int rowcount = 0;
                        while (reader.Read()) {
                            if (rowcount == 0) {
                                databaseNames += reader.GetString(0);
                            } else {
                                databaseNames = reader.GetString(0) + "," + databaseNames;
                            }
                            rowcount += 1;
                        }
                    }
                }
            }
            var host = new WebHostBuilder()
                .UseKestrel()
                .UseUrls("http://0.0.0.0:8090")
                .Configure(app => app.Run(async context => {
                    await context.Response.WriteAsync("The databases are: " + databaseNames);
                }))
                .Build();

            host.Run();
        }

    }
}