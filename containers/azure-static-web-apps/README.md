# Azure Static Web Apps

## Summary

*Develop Azure Static Web Apps & Azure Functions in any supported language. Includes Node.js, eslint, Python, .NET Core, the Azure Functions SDK, and related extensions and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The Azure Functions Team & alvaro.videla@microsoft.com & yohan.lasorsa@microsoft.com|
| *Categories* | Services, Azure |
| *Definition type* | Dockerfile |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Azure Functions, Python, C#, Node.js, JavaScript |

## Using this definition

This definition requires an Azure subscription to use. You can create a [free account here](https://azure.microsoft.com/en-us/free/serverless/) and learn more about using [Azure Functions with VS Code here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-vs-code).

This definition includes Python, .NET Core, and Node.js. Node.js is installed using [nvm](https://github.com/nvm-sh/nvm), so you can use it to pick a different version if needed.

### Adding the definition to your folder

Once you have an Azure account, follow these steps:

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**. 

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

Take a look at the files inside `./test-project/.vscode.sample` to see if you need to adapt the settings for Live Server, or the Azure Functions Core Tools, specifically `settings.json` or `tasks.json`.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/azure-static-web-apps` folder.
5. After the folder has opened in the container, copy the folder `./test-project/.vscode.sample` to `.vscode`, so that the proper settings for running Azure Functions are loaded (this is only needed for testing). Press <kbd>F1</kbd> and type "Reload Window" for the config changes to take effect.
6. Copy `./test-project/api/local.settings.json.sample` into `./test-project/api/local.settings.json`
7. press <kbd>F1</kbd> and select **Live Server: Open with Live Server**.
8. Press <kbd>F5</kbd> to start debugging project.
9. After the debugger is started, open a local browser and enter the URL: `http://localhost:5500`.
    - If the port 7071 is not already open, press <kbd>F1</kbd>, select **Remote-Containers: Forward Port from Container...**, and then port 7071.
10. You should see the "Vanilla Javascript App" with the message "Loading content from the API: Hello from the API" and the result from Azure Function.
11. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
