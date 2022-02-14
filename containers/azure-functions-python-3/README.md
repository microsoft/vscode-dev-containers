# Azure Functions & Python 3

## Summary

*Develop Azure Functions in Python. Includes Python 3, the Azure Functions SDK, Docker CLI (required to publish to Azure with native dependencies) and related extensions and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The Azure Functions Team |
| *Categories* | Services, Azure |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Azure Functions, Python |

## Using this definition

This definition requires an Azure subscription to use. You can create a [free account here](https://azure.microsoft.com/en-us/free/serverless/) and learn more about using [Azure Functions with VS Code here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-vs-code). Once you have an Azure account, follow these steps:

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
4. Select the `containers/azure-functions-python-3` folder.
5. After the folder has opened in the container, press <kbd>F1</kbd> and select **Azure Functions: Create Function...**.
6. Enter these options:
   1. Yes (when prompted to create a new project)
   1. Python
   1. Python3
   1. HTTP Trigger
   1. HTTPTrigger
   1. Anonymous
   1. Open in current window
7. Press <kbd>F5</kbd> to start debugging project.
8. After the debugger is started, open a local browser and enter the URL: `http://localhost:7071/api/HttpTrigger?name=remote`.
    - If the port 7071 is not already open, press <kbd>F1</kbd>, select **Remote-Containers: Forward Port from Container...**, and then port 7071.
9. You should see "Hello remote" echoed by the Azure Function.
10. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
