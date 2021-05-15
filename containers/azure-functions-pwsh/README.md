# Azure Functions & PowerShell

## Summary

*Develop Azure Functions in PowerShell. Includes .NET Core , PowerShell, the Azure Functions SDK, and related extensions and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The Azure Functions Team, [@brettmillerb](https://github.com/brettmillerb) |
| *Categories* | Services, Azure |
| *Definition type* | Dockerfile |
| *Published images* | mcr.microsoft.com/azure-functions/powershell |
| *Available image variants* | 6, 7 |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Azure Functions, .NET Core, PowerShell |

## Using this definition

### Configuration

While the definition itself works unmodified, you can select the version of PowerShell the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "7" }
```

Beyond PowerShell and `git`, this image / `Dockerfile` includes the Az PowerShell module and all required Az modules, Azure CLI, a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

### Adding the definition to a project or codespace

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
4. Select the `containers/azure-functions-pwsh` folder.
5. After the folder has opened in the container, press <kbd>F1</kbd> and select **Azure Functions: Create Function...**.
6. Enter these options:
   1. Yes (when prompted to create a new project)
   2. powershell
   3. HTTP Trigger
   4. HttpTriggerPowerShell
   5. Anonymous
   6. Open in current window
7. Press <kbd>F5</kbd> to start debugging project.
8. After the debugger is started, open a local browser and enter the URL: `http://localhost:7071/api/HttpTriggerPowerShell?name=remote`.
    - If the port 7071 is not already open, press <kbd>F1</kbd>, select **Remote-Containers: Forward Port from Container...**, and then port 7071.
9.  You should see "Hello, remote" echoed by the Azure Function.
10. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
