# Dapr with C# (Community)

## Summary

*Develop Dapr applications using C# and .NET. Includes all needed SDKs, extensions, and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The Visual Studio Container Tools team |
| *Categories* | Community, Frameworks |
| *Definition type* | Docker Compose |
| *Works in Codespaces* | No |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | .NET Core, C#, Dapr |

## Dapr Notes

When the dev container is created, the definition automatically initializes Dapr on a separate Docker network (to isolate it from Dapr instances running locally or in another Dapr dev container). This is done via the `postCreateCommand` in the `.devcontainer/devcontainer.json` and the `DAPR_NETWORK` environment variable in the `.devcontainer/docker-compose.yml`.

## Using this definition

While the definition itself works unmodified, there are some tips that can help you deal with some of the defaults .NET Core uses.

### Using `ports` with ASP.NET Core

By default, ASP.NET Core only listens to localhost. If you use the `ports` property in `.devcontainer/docker-compose.yml`, the port is [published](https://docs.docker.com/config/containers/container-networking/#published-ports) rather than forwarded. Unfortunately, means that ASP.NET Core only listens to localhost is inside the container itself. It needs to listen to `*` or `0.0.0.0` for the application to be accessible externally.

This container solves that problem by setting the environment variable `ASPNETCORE_Kestrel__Endpoints__Http__Url` to `http://*:5000` in `.devcontainer/docker-compose.yml`. Using an environment variable to override this setting in the container only, which allows you to leave your actual application config as-is for use when running locally.

`.devcontainer/docker-compose.yml`:

```yaml
environment:
  ASPNETCORE_Kestrel__Endpoints__Http__Url: http://*:5000
ports:
  - 5000
```

If you've already opened your folder in a container, rebuild the container using the **Remote-Containers: Rebuild Container** command from the Command Palette (<kbd>F1</kbd>) so the settings take effect.

### Debug Configuration

Only the integrated terminal is supported by the Remote - Containers extension. You may need to modify `launch.json` configurations to include the following value if an external console is used.

```json
"console": "integratedTerminal"
```

### Installing Node.js or the Azure CLI

Given how frequently ASP.NET applications use Node.js for front end code, this container also includes Node.js. You can change the version of Node.js installed or disable its installation by updating these lines in `.devcontainer/docker-compose.yml`.

```yaml
arg:
  NODE_VERSION: "14" # Set to "none" to skip Node.js installation
```

If you would like to install the Azure CLI update this line in `.devcontainer/docker-compose.yml`:

```yaml
arg:
  INSTALL_AZURE_CLI: "true"
  NODE_VERSION: "lts"
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
4. Select the `containers/dapr-dotnetcore-latest` folder.
5. After the folder has opened in the container, if prompted to restore packages in a notification, click "Restore".
6. Start the application with Dapr:

    ```bash
    $ cd test-project
    $ dapr run --app-id test --app-port 5000 --dapr-http-port 3500 dotnet run
    ```

7. In a separate terminal, invoke the application via Dapr:

    ```bash
    # Deposit funds to the account (creating the account if not exists)
    $ curl -d 42 -H "Content-Type: application/json" -w "\n" -X POST http://localhost:3500/v1.0/invoke/test/method/accounts/123/deposit
    42
    # Withdraws funds from the account
    $ curl -d 10 -H "Content-Type: application/json" -w "\n" -X POST http://localhost:3500/v1.0/invoke/test/method/accounts/123/withdraw
    32
    # Get the balance of the account
    $ curl -w "\n" http://localhost:3500/v1.0/invoke/test/method/accounts/123
    32
    $
    ```

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
