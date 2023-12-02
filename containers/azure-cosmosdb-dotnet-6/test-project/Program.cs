// https://learn.microsoft.com/en-us/azure/cosmos-db/sql/quickstart-dotnet

using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;

// Get an environment name from environment variable
string environmentName = Environment.GetEnvironmentVariable("DOTNET_ENVIRONMENT") ?? "Development";

// Build a config object, using env vars and JSON providers.
IConfiguration config = new ConfigurationBuilder()
    .AddJsonFile("appsettings.json")
    .AddJsonFile($"appsettings.{environmentName}.json")
    .AddEnvironmentVariables()
    .Build();

// New instance of CosmosClient class
using CosmosClient client = new(
    accountEndpoint: config.GetValue<string>("Cosmos:Endpoint")!,
    authKeyOrResourceToken: config.GetValue<string>("Cosmos:Key")!
);

// Database reference with creation if it does not already exist
Database database = await client.CreateDatabaseIfNotExistsAsync(
    id: "adventureworks"
);

Console.WriteLine($"New database:\t{database.Id}");

// Container reference with creation if it does not alredy exist
Container container = await database.CreateContainerIfNotExistsAsync(
    id: "products",
    partitionKeyPath: "/category",
    throughput: 400
);

Console.WriteLine($"New container:\t{container.Id}");

// Create new object and upsert (create or replace) to container
Product newItem = new(
    id: "68719518391",
    category: "gear-surf-surfboards",
    name: "Yamba Surfboard",
    quantity: 12,
    sale: false
);

Product createdItem = await container.UpsertItemAsync<Product>(
    item: newItem,
    partitionKey: new PartitionKey("gear-surf-surfboards")
);

Console.WriteLine($"Created item:\t{createdItem.id}\t[{createdItem.category}]");

// Point read item from container using the id and partitionKey
Product readItem = await container.ReadItemAsync<Product>(
    id: "68719518391",
    partitionKey: new PartitionKey("gear-surf-surfboards")
);

// Create query using a SQL string and parameters
var query = new QueryDefinition(
    query: "SELECT * FROM products p WHERE p.category = @key"
)
    .WithParameter("@key", "gear-surf-surfboards");

using FeedIterator<Product> feed = container.GetItemQueryIterator<Product>(
    queryDefinition: query
);

while (feed.HasMoreResults)
{
    FeedResponse<Product> response = await feed.ReadNextAsync();
    foreach (Product item in response)
    {
        Console.WriteLine($"Found item:\t{item.name}");
    }
}
