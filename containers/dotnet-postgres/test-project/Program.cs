/*-------------------------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
 *-------------------------------------------------------------------------------------------------------------*/

using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;
using Npgsql;

namespace aspnetapp
{
    public class Program
    {
        private static string Host = "db";
        private static string User = "postgres";
        private static string DBname = "postgres";
        private static string Password = "postgres";
        private static string Port = "5432";

        public static async Task Main(string[] args)
        {
            string databaseNames = "";

            var connString = $"Host={Host};Port={Port};Username={User};Password={Password};Database={DBname}";

            await using var conn = new NpgsqlConnection(connString);
            await conn.OpenAsync();

            await using (var query = new NpgsqlCommand("SELECT datname FROM pg_database", conn))
            await using (var reader = await query.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                    databaseNames += $"{reader.GetString(0)}, ";
            }

            databaseNames = databaseNames.Substring(0, databaseNames.Length - 2);
            var host = new WebHostBuilder()
                .UseKestrel()
                .UseUrls("http://0.0.0.0:8090")
                .Configure(app => app.Run(async context =>
                {
                    await context.Response.WriteAsync("The databases are: " + databaseNames);
                }))
                .Build();

            host.Run();
        }
    }
}