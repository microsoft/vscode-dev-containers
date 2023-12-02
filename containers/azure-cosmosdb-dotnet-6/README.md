# C# (.NET) and Azure Cosmos DB

## Summary

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Yuta Matsumura](https://github.com/tsubakimoto) |
| *Categories* | Services, Azure |
| *Definition type* | Docker Compose |
| *Published image architecture(s)* | x86-64 |
| *Available image variants* | 6.0-focal |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS |
| *Container OS* | Ubuntu (`-focal`), Debian (`-bullseye`) |
| *Languages, platforms* | .NET, .NET Core, C#, Microsoft Azure |

## Descirption
This definition creates two containers, one for C# (.NET) and one for [Azure Cosmos DB Emulator](https://learn.microsoft.com/en-us/azure/cosmos-db/linux-emulator). VS Code will attach to the .NET Core container, and from within that container the Azure Cosmos DB Emulator container will be available on **`localhost`** port 8081. For more on the configuration of Azure Cosmos DB Emulator, see the document [Configuration options](https://learn.microsoft.com/en-us/azure/cosmos-db/linux-emulator#configuration-options)

## Using this definition

**[Optional] Include any special setup requirements here. For example:**

While the definition itself works unmodified, you can select the version of **YOUR RUNTIME HERE** the container uses by updating the `VARIANT` arg in the included `.devcontainer/devcontainer.json` file.

```json
"args": { "VARIANT": "6.0-bullseye" }
```

### Using the forwardPorts property

```json
"forwardPorts": [ 8081 ]
```

This port is used by Azure Cosmos DB Emulator to expose Explorer. The explorer can be accessed at https://localhost:8081/_explorer/index.html .

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/azure-cosmosdb-emulator` folder.
5. After the folder has opened in the container, if prompted to restore packages in a notification, click "Restore".
6. After packages are restored, run `dotnet run --project test-project/app.csproj` in `.
7. Open the browser to [https://localhost:8081/_explorer/index.html](https://localhost:8081/_explorer/index.html).
8. You should see "Azure Cosmos DB Emulator Explorer" and see added items.
9. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.
