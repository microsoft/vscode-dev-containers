# C++ & MariaDB

## Summary

*Develop C++ applications on Linux. Includes Debian C++ build tools.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Categories* | Core, Languages |
| *Definition type* | Docker Compose |
| *Available image variants* | [See cpp definition](../cpp). |
| *Supported architecture(s)* | x86-64, aarch64/arm64 for `bullseye`, `stretch`, `bionic`, and `hirsute` variants |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian, Ubuntu |
| *Languages, platforms* | C++ |

## Using this definition
This definition creates two containers, one for C++ and one for MariaDB (MySQL). VS Code will attach to the C++ dev container, and from within that container the MariaDB container will be available on **`localhost`** port 3306. The `.env` file sets the default credentials for the MariaDB Database. The default database is named `mariadb` with a user of `mariadb` whose password is `mariadb`, and if desired this may be changed in `.env`. Data is stored in a volume named `mariadb-data`.


While the definition itself works unmodified, you can select the version of Debian or Ubuntu the container uses by updating the `VARIANT` arg in `.devcontainer/docker-compose.yml` (and rebuilding if you've already created the container).

```yaml
build: 
  context: .
  dockerfile: Dockerfile
    args:
      # Update 'VARIANT' to pick a version of CPP
      # See the README for more information on available versions.
      VARIANT: debian-11
```

Beyond `git`, this image / `Dockerfile` includes `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Using the MariaDB Database
You can connect to MariaDB from an external tool when using VS Code by updating `.devcontainer/devcontainer.json` as follows:

```json
"forwardPorts": [ "3306" ]
```

Once the MariaDB container has port forwarding enabled, it will be accessible from the Host machine at `localhost:3306`. The [MariaDB Documentation](https://mariadb.com/docs/) has:

1. [An Installation Guide for MySQL](https://mariadb.com/kb/en/mysql-client/), a CLI tool to work with a MariaDB database.
2. [Tips on populating data](https://mariadb.com/kb/en/how-to-quickly-insert-data-into-mariadb/) in the database. 

If needed, you can use `postCreateCommand` to run commands after the container is created, by updating `.devcontainer/devcontainer.json` similar to what follows:

```json
"postCreateCommand": "g++ --version && git --version"
```

### Adding another service

You can add other services to your `docker-compose.yml` file [as described in Docker's documentation](https://docs.docker.com/compose/compose-file/#service-configuration-reference). However, if you want anything running in this service to be available in the container on localhost, or want to forward the service locally, be sure to add this line to the service config:

```yaml
# Runs the service on the same network as the database container, allows "forwardPorts" in devcontainer.json function.
network_mode: service:[$SERVICENAME]
```

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/cpp-mariadb` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see the following in the a terminal window after the program finishes executing.
```
Hello, Remote World!
DB Connecting
DB Executing
Cluster has the following user created databases
mariadb
DB Success
```
7. You can also run [test.sh](test-project/test.sh) in order to build and test the project.
8. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

### Debugging Security
To allow C++ based debuggers to run within the Docker Containers, the [docker-compose.yml](.devcontainer/docker-compose.yml) contains the following lines which can be uncommented::

```yaml
    security_opt:
      - seccomp:unconfined
    cap_add:
      - SYS_PTRACE
```

As these can create security vulnerabilities, it is advisable to not use this unless needed. This should only be used in a Debug or Dev container, not in Production.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
