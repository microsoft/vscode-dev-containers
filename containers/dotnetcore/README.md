# C# (.NET Core)

## Summary

*Develop C# and .NET Core based applications. Includes all needed SDKs, extensions, and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | .NET Core, C# |

## Using this definition with an existing folder

While this definition should work unmodified, you can select the version of .NET Core the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "3.1-bionic" }
```

In addition there are a number of options that can be set to customize your environment.

### Debug Configuration

Only the integrated terminal is supported by the Remote - Containers extension. You may need to modify your `.vscode/launch.json` configurations to include the following:

```json
"console": "integratedTerminal"
```

### Using the forwardPorts property

By default, ASP.NET Core only listens to localhost inside the container. As a result, we recommend using the `forwardPorts` property in `.devcontainer/devcontainer.json` (available in v0.98.0+) to make these ports available locally.

```json
"forwardPorts": [5000, 5001]
```

The `appPort` property [publishes](https://docs.docker.com/config/containers/container-networking/#published-ports) rather than forwards the port, so applications need to listen to `*` or `0.0.0.0` for the application to be accessible externally. This conflicts with ASP.NET Core's defaults, but fortunately the `forwardPorts` property does not have this limitation.

> **Note:** See [here for an alternative](https://github.com/microsoft/vscode-dev-containers/blob/v0.42.0/containers/dotnetcore-2.1/README.md#using-appport-with-aspnet-core) using `appPort` if you need to use an extension version below v0.98.0.

If you've already opened your folder in a container, rebuild the container using the **Remote-Containers: Rebuild Container** command from the Command Palette (<kbd>F1</kbd>) so the settings take effect.

### Enabling HTTPS in ASP.NET Core

To enable HTTPS in ASP.NET, you can mount an exported copy of your local dev certificate. First, export it using the following command:

**Windows PowerShell**

```powershell
dotnet dev-certs https --trust; dotnet dev-certs https -ep "$env:USERPROFILE/.aspnet/https/aspnetapp.pfx" -p "SecurePwdGoesHere"
```

**macOS/Linux terminal**

```powershell
dotnet dev-certs https --trust; dotnet dev-certs https -ep "${HOME}/.aspnet/https/aspnetapp.pfx" -p "SecurePwdGoesHere"
```

Next, add the following in to `.devcontainer/devcontainer.json` (assuming port 5000 and 5001 are the correct ports):

```json
"forwardPorts": [5000, 5001],
"mounts": [
    "source=${env:HOME}${env:USERPROFILE}/.aspnet/https,target=/home/vscode/.aspnet/https,type=bind"
],
"remoteEnv": {
    "ASPNETCORE_Kestrel__Certificates__Default__Password": "SecurePwdGoesHere",
    "ASPNETCORE_Kestrel__Certificates__Default__Path": "/home/vscode/.aspnet/https/aspnetapp.pfx"
}
```

> **Note:** See [here for an alternative](https://github.com/microsoft/vscode-dev-containers/blob/v0.42.0/containers/dotnetcore-2.1/README.md#enabling-https-in-aspnet-core) when using an extension version below v0.98.0 as the `forwardPorts` property is not available.

If you've already opened your folder in a container, rebuild the container using the **Remote-Containers: Rebuild Container** command from the Command Palette (<kbd>F1</kbd>) so the settings take effect.

### Installing Node.js or the Azure CLI

Given how frequently ASP.NET applications use Node.js for front end code, this container also includes Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.

```json
"args": {
    "VARIANT": "3.1-bionic",
    "INSTALL_NODE": "true",
    "NODE_VERSION": "10",
}
```

If you would like to install the Azure CLI update you can set the `INSTALL_AZURE_CLI` argument line in `.devcontainer/devcontainer.json`:

```Dockerfile
"args": {
    "VARIANT": "3.1-bionic",
    "INSTALL_NODE": "true",
    "NODE_VERSION": "10",
    "INSTALL_AZURE_CLI": "true"
}
```

If you've already opened your folder in a container, rebuild the container using the **Remote-Containers: Rebuild Container** command from the Command Palette (<kbd>F1</kbd>) so the settings take effect.

### Adding the definition to your folder

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the C# (.NET Core) definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/dotnetcore/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/dotnetcore` folder.
5. After the folder has opened in the container, if prompted to restore packages in a notification, click "Restore".
6. After packages are restored, press <kbd>F5</kbd> to start the project.
7. Once the project is running, press <kbd>F1</kbd> and select **Remote-Containers: Forward Port from Container...**
8. Select port 8090 and click the "Open Browser" button in the notification that appears.
9. You should see "Hello remote world from ASP.NET Core!" after the page loads.
10. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
