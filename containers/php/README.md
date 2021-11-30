# PHP

## Summary

*Develop PHP based applications. Includes needed tools, extensions, and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Categories* | Languages |
| *Definition type* | Dockerfile |
| *Published images* | mcr.microsoft.com/vscode/devcontainers/php |
| *Available image variants* | 8 / 8-bullseye, 8.1 / 8.1-bullseye, 8.0 / 8.0-bullseye, 7 / 7-bullseye, 7.4 / 7.4-bullseye, 8-buster, 8.1-buster, 8.0-buster, 7-buster, 7.5-buster ([full list](https://mcr.microsoft.com/v2/vscode/devcontainers/php/tags/list)) |
| *Published image architecture(s)* | x86-64, arm64/aarch64 for `bullseye` variants |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | PHP |

See **[history](history)** for information on the contents of published images.

## Using this definition

While the definition itself works unmodified, you can select the version of PHP the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
// Or you can use 7-bullseye or 7-buster if you want to pin to an OS version
"args": { "VARIANT": "7" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own `Dockerfile` with one of the following:

- `mcr.microsoft.com/vscode/devcontainers/php` (latest)
- `mcr.microsoft.com/vscode/devcontainers/php:8` (or `8-bullseye`, `8-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/php:8.1` (or `8.1-bullseye`, `8.1-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/php:8.0` (or `8.0-bullseye`, `8.0-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/php:7` (or `7-bullseye`, `7-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/php:7.4` (or `7.4-bullseye`, `7.4-buster` to pin to an OS version)

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `mcr.microsoft.com/vscode/devcontainers/python:0-7` (or `0-7-bullseye`, `0-7-buster`)
- `mcr.microsoft.com/vscode/devcontainers/python:0.203-7` (or `0.203-7-bullseye`, `0.203-7-buster`)
- `mcr.microsoft.com/vscode/devcontainers/python:0.203.0-7` (or `0.203.0-7-bullseye`, `0.203.0-7-buster`)

However, we only do security patching on the latest [non-breaking, in support](https://github.com/microsoft/vscode-dev-containers/issues/532) versions of images (e.g. `0-7`). You may want to run `apt-get update && apt-get upgrade` in your Dockerfile if you lock to a more specific version to at least pick up OS security updates.

See [history](history) for information on the contents of each version and [here for a complete list of available tags](https://mcr.microsoft.com/v2/vscode/devcontainers/php/tags/list).

Alternatively, you can use the contents of `base.Dockerfile` to fully customize your container's contents or to build it for a container host architecture not supported by the image.

### Installing Node.js

Given JavaScript front-end web client code written for use in conjunction with a PHP back-end often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.

```jsonc
"args": {
    "VARIANT": "7",
    "NODE_VERSION": "14" // Set to "none" to skip Node.js installation
}
```

### Starting / stopping Apache

This dev container includes Apache in addition to the PHP CLI. While you can use PHP's built in CLI (e.g. `php -S 0.0.0.0:8080`), you can start Apache by running:

```bash
apache2ctl start
```

Apache will be available on port `8080`.

If you want to wire in something directly from your source code into the `www` folder, you can add a symlink as follows to `postCreateCommand`:

```json
"postCreateCommand": "sudo chmod a+x \"$(pwd)\" && sudo rm -rf /var/www/html && sudo ln -s \"$(pwd)\" /var/www/html"
```

...or execute this from a terminal window once the container is up:

```bash
sudo chmod a+x "$(pwd)" && sudo rm -rf /var/www/html && sudo ln -s "$(pwd)" /var/www/html
```

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. To use the pre-built image:
   1. Start VS Code and open your project folder or connect to a codespace.
   2. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.
   4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

3. To build a custom version of the image instead:
   1. Clone this repository locally.
   2. Start VS Code and open your project folder or connect to a codespace.
   3. Use your local operating system's file explorer to drag-and-drop the locally cloned copy of the `.devcontainer` folder for this definition into the VS Code file explorer for your opened project or codespace.
   4. Update `.devcontainer/devcontainer.json` to reference `"dockerfile": "base.Dockerfile"`.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/php` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "Hello remote world!" in the Debug Console after the program executes.
7. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).