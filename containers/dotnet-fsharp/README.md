# F# (.NET)

## Summary

*Develop F# and .NET based applications. Includes all needed SDKs, extensions, and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team, F# team |
| *Categories* | Languages |
| *Definition type* | Dockerfile |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Ubuntu |
| *Languages, platforms* | .NET, .NET Core, F# |

## Using this definition

While this definition should work unmodified, you can select the version of .NET / .NET Core the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "3.1" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own  `Dockerfile` to one of the following. An example `Dockerfile` is included in this repository.

- `mcr.microsoft.com/vscode/devcontainers/dotnet` (latest)
- `mcr.microsoft.com/vscode/devcontainers/dotnet:2.1` (or `dotnetcore:2.1`)
- `mcr.microsoft.com/vscode/devcontainers/dotnet:3.1` (or `dotnetcore:3.1`)
- `mcr.microsoft.com/vscode/devcontainers/dotnet:5.0`

Version specific tags tied to [releases in this repository](https://github.com/microsoft/vscode-dev-containers/releases) are also available.

- `mcr.microsoft.com/vscode/devcontainers/dotnet:0-3.1`
- `mcr.microsoft.com/vscode/devcontainers/dotnet:0.149-3.1`
- `mcr.microsoft.com/vscode/devcontainers/dotnet:0.149.0-3.1`

Alternatively, you can use the [contents of this `base.Dockerfile`](../dotnetcore/..devcontainer/base.Dockerfile) to fully customize your container's contents or to build it for a container host architecture not supported by the image.

### Debug Configuration

Only the integrated terminal is supported by the Remote - Containers extension. You may need to modify your `.vscode/launch.json` configurations to include the following:

```json
"console": "integratedTerminal"
```

**Note:** Currently the Ionide-fsharp extension appears to force the use of an external console when clicking on the Debug icon in the F# Solution Explorer. You can configure a .NET application launch [in `launch.json`](https://code.visualstudio.com/Docs/editor/debugging#_launch-configurations) with the property above instead.

### Using the forwardPorts property

By default, ASP.NET Core only listens to localhost inside the container. As a result, we recommend using the `forwardPorts` property in `.devcontainer/devcontainer.json` (available in v0.98.0+) to make these ports available locally.

```json
"forwardPorts": [5000, 5001]
```

The `appPort` property [publishes](https://docs.docker.com/config/containers/container-networking/#published-ports) rather than forwards the port, so applications need to listen to `*` or `0.0.0.0` for the application to be accessible externally. This conflicts with ASP.NET Core's defaults, but fortunately the `forwardPorts` property does not have this limitation.
If you've already opened your folder in a container, rebuild the container using the **Remote-Containers: Rebuild Container** command from the Command Palette (<kbd>F1</kbd>) so the settings take effect.

### Enabling HTTPS in ASP.NET Core

To enable HTTPS in ASP.NET, you can mount an exported copy of your local dev certificate.

1. Export it using the following command:

    **Windows PowerShell**

    ```powershell
    dotnet dev-certs https --trust; dotnet dev-certs https -ep "$env:USERPROFILE/.aspnet/https/aspnetapp.pfx" -p "SecurePwdGoesHere"
    ```

    **macOS/Linux terminal**

    ```powershell
    dotnet dev-certs https --trust; dotnet dev-certs https -ep "${HOME}/.aspnet/https/aspnetapp.pfx" -p "SecurePwdGoesHere"
    ```

2. Add the following in to `.devcontainer/devcontainer.json`:

    ```json
    "remoteEnv": {
        "ASPNETCORE_Kestrel__Certificates__Default__Password": "SecurePwdGoesHere",
        "ASPNETCORE_Kestrel__Certificates__Default__Path": "/home/vscode/.aspnet/https/aspnetapp.pfx",
    }
    ```

3. Finally, make the certificate available in the container as follows:

    **If using GitHub Codespaces and/or Remote - Containers**

    1. Start the container/codespace
    2. Drag `~/.aspnet/https/aspnetapp.pfx` from your local machine into the root of the File Explorer in VS Code.
    3. Open a terminal in VS Code and run:
        ```bash
        mkdir -p /home/vscode/.aspnet/https && mv aspnetapp.pfx /home/vscode/.aspnet/https
        ```

    **If using only Remote - Containers with a local container**

    Add the following to `.devcontainer/devcontainer.json`:

    ```json
    "mounts": [ "source=${env:HOME}${env:USERPROFILE}/.aspnet/https,target=/home/vscode/.aspnet/https,type=bind" ]
    ```

If you've already opened your folder in a container, rebuild the container using the **Remote-Containers: Rebuild Container** command from the Command Palette (<kbd>F1</kbd>) so the settings take effect.

### Installing Node.js or the Azure CLI

Given JavaScript front-end web client code written for use in conjunction with an ASP.NET back-end often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.

```jsonc
"args": {
    "VARIANT": "3.1",
    "NODE_VERSION": "14" // Set to "none" to skip Node.js installation
}
```

If you would like to install the Azure CLI update you can set the `INSTALL_AZURE_CLI` argument line in `.devcontainer/devcontainer.json`:

```json
"args": {
    "VARIANT": "3.1",
    "NODE_VERSION": "14",
    "INSTALL_AZURE_CLI": "true"
}
```

If you've already opened your folder in a container, rebuild the container using the **Remote-Containers: Rebuild Container** command from the Command Palette (<kbd>F1</kbd>) so the settings take effect.

### Adding the definition to your folder

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
4. Select the `containers/dotnetcore-fsharp` folder.
5. When prompted click "Restore" in the notification to restore packages.
6. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
7. You should see "Hello Remote World from the F# Container!" in a terminal window after the program executes.
8. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
