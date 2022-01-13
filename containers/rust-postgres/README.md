# Rust & PostgreSQL

## Summary

*Develop applications with Rust and PostgreSQL. Includes a Rust application container and PostgreSQL server.*

| Metadata | Value |
|----------|-------|
| *Contributors* | The VS Code Team |
| *Categories* | Core, Languages |
| *Definition type* | Docker Compose |
| *Available image variants* | buster, bullseye ([full list](https://mcr.microsoft.com/v2/vscode/devcontainers/rust/tags/list)) |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Rust |

## Using this definition

This definition creates two containers, one for Rust and one for PostgreSQL. VS Code will attach to the Rust dev container, and from within that container the PostgreSQL container will be available on **`localhost`** port 5432. The `.env` file sets the default credentials. The default database is named `postgres` with a user of `postgres` whose password is `postgres`, and if desired this may be changed in `docker-compose.yml`. Data is stored in a volume named `postgres-data`.

While the definition itself works unmodified, you can select the version of Debian the container uses by updating the `VARIANT` arg in `.devcontainer/docker-compose.yml` (and rebuilding if you've already created the container).

```yaml
build:
      context: .
      dockerfile: Dockerfile
      args:
        # Use the VARIANT arg to pick a Debian OS version: buster, bullseye
        # Use bullseye when on local on arm64/Apple Silicon.
        VARIANT: buster
```

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

### Adding another service

You can add other services to your `docker-compose.yml` file [as described in Docker's documentation](https://docs.docker.com/compose/compose-file/#service-configuration-reference). However, if you want anything running in this service to be available in the container on localhost, or want to forward the service locally, be sure to add this line to the service config:

```yaml
# Runs the service on the same network as the database container, allows "forwardPorts" in devcontainer.json function.
network_mode: service:[$SERVICENAME]
```

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
1. Clone this repository.
1. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
1. Select the `containers/rust-postgres` folder.
1. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
1. You should see "Hello, VS Code Remote - Containers!" in the Debug Console after the program executes.
1. You can also run [test.sh](test-project/test.sh) in order to build and test the project.
1. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
