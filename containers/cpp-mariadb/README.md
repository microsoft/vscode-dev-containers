# C++

## Summary

*Develop C++ applications on Linux. Includes Debian C++ build tools.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Categories* | Core, Languages |
| *Definition type* | Dockerfile |
| *Available image variants* | stretch, buster, bullseye, bionic, focal, hirsute ([full list](https://mcr.microsoft.com/v2/vscode/devcontainers/cpp/tags/list)) |
| *Published image architecture(s)* | x86-64, aarch64/arm64 for `bullseye`, `stretch`, `bionic`, and `hirsute` variants |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian, Ubuntu |
| *Languages, platforms* | C++ |

See **[history](history)** for information on the contents of published images.

## Using this definition
This definition creates two containers, one for C++ and one for MariaDB (MySQL). VS Code will attach to the C++ dev container, and from within that container the MariaDB container will be available on **`localhost`** port 5432. The default database is named `mariadb` with a user of `mariadb` whose password is `mariadb`, and if desired this may be changed in `docker-compose.yml`. Data is stored in a volume named `mariadb-data`.


While the definition itself works unmodified, you can select the version of Debian or Ubuntu the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "bullseye" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own  `Dockerfile` to one of the following. An example `Dockerfile` is included in this repository.

- `mcr.microsoft.com/vscode/devcontainers/cpp` (latest Debian GA)
- `mcr.microsoft.com/vscode/devcontainers/cpp:debian` (latest Debian GA)
- `mcr.microsoft.com/vscode/devcontainers/cpp:bullseye` (or `debian-11`)
- `mcr.microsoft.com/vscode/devcontainers/cpp:buster` (or `debian-10`)
- `mcr.microsoft.com/vscode/devcontainers/cpp:stretch` (or `debian-9`)
- `mcr.microsoft.com/vscode/devcontainers/cpp:ubuntu` (latest Ubuntu LTS)
- `mcr.microsoft.com/vscode/devcontainers/cpp:hirsute` (or `ubuntu-21.04`)
- `mcr.microsoft.com/vscode/devcontainers/cpp:focal` (or `ubuntu-20.04`)
- `mcr.microsoft.com/vscode/devcontainers/cpp:bionic` (or `ubuntu-18.04`)

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `mcr.microsoft.com/vscode/devcontainers/cpp:0-bullseye`
- `mcr.microsoft.com/vscode/devcontainers/cpp:0.203-bullseye`
- `mcr.microsoft.com/vscode/devcontainers/cpp:0.203.0-bullseye`

However, we only do security patching on the latest [non-breaking, in support](https://github.com/microsoft/vscode-dev-containers/issues/532) versions of images (e.g. `0-bullseye`). You may want to run `apt-get update && apt-get upgrade` in your Dockerfile if you lock to a more specific version to at least pick up OS security updates.

See [history](history) for information on the contents of each version and [here for a complete list of available tags](https://mcr.microsoft.com/v2/vscode/devcontainers/cpp/tags/list).

Alternatively, you can use the contents of `base.Dockerfile` to fully customize your container's contents or to build it for a container host architecture not supported by the image.

Beyond `git`, this image / `Dockerfile` includes `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. To use the pre-built image:
   1. Start VS Code and open your project folder or connect to a codespace.
   2. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.
   3. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

3. To build a custom version of the image instead:
   1. Clone this repository locally.
   2. Start VS Code and open your project folder or connect to a codespace.
   3. Use your local operating system's file explorer to drag-and-drop the locally cloned copy of the `.devcontainer` folder for this definition into the VS Code file explorer for your opened project or codespace.
   4. Update `.devcontainer/devcontainer.json` to reference `"dockerfile": "base.Dockerfile"`.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.
   1. We recommend setting up your workspace with `g++ (Debian 10.2.1-6)` or later as MariaDB explicitly supports `g++` and all testing has been done with `g++`.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Using the MariaDB Database
You can connect to MariaDB from an external tool when using VS Code by updating `.devcontainer/devcontainer.json` as follows:

```json
"forwardPorts": [ "5432" ]
```

Once the MariaDB container has port forwarding enabled, it will be accessible from the Host machine at `localhost:5432`. The [MariaDB Documentation](https://mariadb.com/docs/) has:

1. [An Installation Guide for MySQL](https://mariadb.com/kb/en/mysql-client/), a CLI tool to work with a PostgreSQL database.
2. [Tips on populating data](https://mariadb.com/kb/en/how-to-quickly-insert-data-into-mariadb/) in the database. 

If needed, you can use `postCreateCommand` to run commands after the container is created, by updating `.devcontainer/devcontainer.json` similar to what follows:

```json
"postCreateCommand": "g++ --version && git --version"
```



## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/cpp` folder.
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

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
