# Azure Functions & Node.js

## Summary

*Develop Azure Functions in Node.js. Includes Node.js, eslint, the Azure Functions SDK, and related extensions and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The Azure Functions Team |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Azure Functions, Node.js, JavaScript |

## Using this definition with an existing folder

This definition requires an Azure subscription to use. You can create a [free account here](https://azure.microsoft.com/en-us/free/serverless/) and learn more about using [Azure Functions with VS Code here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-vs-code).

While this definition should work unmodified, you can select the version of Node.js the container uses by updating the `VARIANT` arg in the included `devcontainer.json` to a supported major Node.js release version.

```json
"args": { "VARIANT": "10" }
```

### Adding the definition to your folder

Once you have an Azure account, follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Azure Functions & Node.js 12 definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/azure-functions-node/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/azure-functions-node` folder.
5. After the folder has opened in the container, press <kbd>F1</kbd> and select **Azure Functions: Create Function...**.
6. Enter these options:
   1. Yes (when prompted to create a new project)
   2. JavaScript
   3. HTTP Trigger
   4. HTTPTrigger
   5. Anonymous
   6. Open in current window
7. Press <kbd>F5</kbd> to start debugging project.
8. After the debugger is started, open a local browser and enter the URL: `http://localhost:7071/api/HttpTrigger?name=remote`.
    - If the port 7071 is not already open, press <kbd>F1</kbd>, select **Remote-Containers: Forward Port from Container...**, and then port 7071.
9. You should see "Hello remote" echoed by the Azure Function.
10. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
