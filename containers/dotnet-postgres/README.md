# C# (.NET) and PostgreSQL (Community)

## Summary

*Develop C# and .NET Core based applications. Includes all needed SDKs, extensions, dependencies and a PostgreSQL container for parallel database development. Adds an additional PostgreSQL container to the C# (.NET Core) container definition.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Berkays](https://github.com/Berkays)  |
| *Categories* | Core, Languages |
| *Definition type* | Docker Compose |
| *Published image architecture(s)* | x86-64, arm64/aarch64 for `bullseye` variants|
| *Available image variants* | [See C# (.NET) definition](../dotnet). |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Ubuntu (`-focal`), Debian (`-bullseye`) |
| *Languages, platforms* | .NET, .NET Core, C#, PostgreSQL |

## Description
This definition creates two containers, one for C# (.NET) and one for PostgreSQL. VS Code will attach to the .NET Core container, and from within that container the PostgreSQL container will be available on **`localhost`** port 5432. By default, the `postgre` user password is `postgre`. Default database parameters may be changed in `docker-compose.yml` file if desired.

## Using this definition

While this definition should work unmodified, you can select the version of .NET Core the container uses by updating the `VARIANT` arg in the included `docker-compose.yml` (and rebuilding if you've already created the container).

```yaml
args:
  VARIANT: "3.1-focal"
```

This will use an Ubuntu 20.04/focal based .NET image by default.

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

    1. Start the container/codespace
    2. Drag `~/.aspnet/https/aspnetapp.pfx` from your local machine into the root of the File Explorer in VS Code.
    3. Open a terminal in VS Code and run:
        ```bash
        mkdir -p /home/vscode/.aspnet/https && mv aspnetapp.pfx /home/vscode/.aspnet/https
        ```

If you've already opened your folder in a container, rebuild the container using the **Remote-Containers: Rebuild Container** command from the Command Palette (<kbd>F1</kbd>) so the settings take effect.

### Installing Node.js or the Azure CLI

Given how frequently ASP.NET applications use Node.js for front end code, this container also includes Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/docker-compose.yml`.

```yaml
args:
  VARIANT: "3.1-focal"
  NODE_VERSION: "16" # Set to "none" to skip Node.js installation
```

If you would like to install the Azure CLI, you can reference [a dev container feature](https://aka.ms/vscode-remote/containers/dev-container-features) by adding the following to `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "azure-cli": "latest"
  }
}
```

If you've already opened your folder in a container, rebuild the container using the **Remote-Containers: Rebuild Container** command from the Command Palette (<kbd>F1</kbd>) so the settings take effect.

## PostgreSQL Configuration
A secondary container for PostgreSQL is defined in `devcontainer.json` and `docker-compose.yml` files. This container is deployed from the latest version available at the time of this commit. `latest` tag is avoided to prevent breaking bugs. The default `postgres` user password is set to `postgres`. The database instance uses the default port of `5432`.

### Changing the postgres user password
To change the `postgres` user password, change the value in `docker-compose.yml` and `devcontainer.json`.

## Adding the definition to your folder

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
4. Select the `containers/dotnet-postgres` folder.
5. After the folder has opened in the container, if prompted to restore packages in a notification, click "Restore".
6. After packages are restored, press <kbd>F5</kbd> to start the project. *Note: if Auto Forward Ports has been disabled, you will need to manually forward port 8090 from the container with "Remote-Containers: Forward Ports..."*
7. Open the browser to [localhost:8090](http://localhost:8090).
8. You should see "The databases are: postgres, template1, template0" after the page loads.
9. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).

Licenses for [POSTGRESQL](https://www.postgresql.org/about/licence/)