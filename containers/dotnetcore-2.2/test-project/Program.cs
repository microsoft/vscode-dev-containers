using System;
using System.Linq;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Builder;
using Newtonsoft.Json;
using Microsoft.AspNetCore.Http;
using System.IO;

namespace aspnetapp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var host = new WebHostBuilder()
                .UseKestrel()
                .UseUrls("http://0.0.0.0:8090")
                .Configure(app => app.Run(async context => {
                    await context.Response.WriteAsync("Hello world from ASP.NET Core");
                }))
                .Build();

            host.Run();
        }

    }
}