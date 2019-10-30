# C# (.NET Core 2.2)

## Summary

*Develop C# and .NET Core 2.2 based applications. Includes all needed SDKs, extensions, and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Definition type* | Dockerfile |
| *Languages, platforms* | .NET Core, C# |

## Using this definition with an existing folder

A few notes on this definition:

1. Only the integrated terminal is supported by the Remote - Containers extension. You may need to modify `launch.json` configurations to include the following value if an external console is used.

    ```json
    "console": "integratedTerminal"
    ```

2. Given how frequently ASP.NET applications use Node.js for front end code, this container also includes Node.js. You can change the version of Node.js installed or disable its installation by updating these lines in `.devcontainer/Dockerfile`.

    ```Dockerfile
    ARG INSTALL_NODE="true"
    ARG NODE_MAJOR_VERSION="10"
    ```

3. If you would like to install the Azure CLI update this line in `.devcontainer/Dockerfile`:

    ```Dockerfile
    ARG INSTALL_AZURE_CLI="true"
    ```

Beyond that, just follow these steps to use the definition:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the C# (.NET Core 2.2) definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/dotnetcore-2.2/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/dotnetcore-2.2` folder.
5. After the folder has opened in the container, if prompted to restore packages in a notification, click "Restore".
6. After packages are restored, press <kbd>F5</kbd> to start the project.
7. Once the project is running, press <kbd>F1</kbd> and select **Remote-Containers: Forward Port from Container...**
8. Select port 8090 and click the "Open Browser" button in the notification that appears.
9. You should see "Hello remote world from ASP.NET Core!" after the page loads.
10. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).