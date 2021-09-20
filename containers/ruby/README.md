# Ruby

## Summary

*Develop Ruby based applications. includes everything you need to get up and running.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Categories* | Core, Languages |
| *Definition type* | Dockerfile |
| *Published images* | mcr.microsoft.com/vscode/devcontainers/ruby |
| *Available image variants* | 3 / 3-bullseye, 3.0 / 3.0-bullseye, 2 / 2-bullseye, 2.7 / 2.7-bullseye, 2.6 / 2.7-bullseye, 3-buster, 3.0-buster, 2-buster, 2.7-buster, 2.6-buster ([full list](https://mcr.microsoft.com/v2/vscode/devcontainers/ruby/tags/list)) |
| *Published image architecture(s)* | x86-64, arm64/aarch64 for `bullseye` variants |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Ruby |

See **[history](history)** for information on the contents of published images.

## Using this definition

While this definition should work unmodified, you can select the version of Ruby the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
// Or you can use 2.7-bullseye or 2.7-buster if you want to pin to an OS version
"args": { "VARIANT": "2.7" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own  `Dockerfile` to one of the following. An example `Dockerfile` is included in this repository.

- `mcr.microsoft.com/vscode/devcontainers/ruby` (latest)
- `mcr.microsoft.com/vscode/devcontainers/ruby:3` (or `3-bullseye`, `3-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/ruby:3.0` (or `3.0-bullseye`, `3.0-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/ruby:2` (or `2-bullseye`, `2-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/ruby:2.7` (or `2.7-bullseye`, `2.7-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/ruby:2.6` (or `2.6-bullseye`, `2.6-buster` to pin to an OS version)

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `mcr.microsoft.com/vscode/devcontainers/ruby:0-3` (or `0-3-bullseye`, `0-3-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/ruby:0.202-3` (or `0.202-3-bullseye`, `0.202-3-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/ruby:0.202.0-3` (or `0.202.0-3-bullseye`, `0.202.0-3-buster` to pin to an OS version)

However, we only do security patching on the latest [non-breaking, in support](https://github.com/microsoft/vscode-dev-containers/issues/532) versions of images (e.g. `0-2.7`). You may want to run `apt-get update && apt-get upgrade` in your Dockerfile if you lock to a more specific version to at least pick up OS security updates.

See [history](history) for information on the contents of each version and [here for a complete list of available tags](https://mcr.microsoft.com/v2/vscode/devcontainers/ruby/tags/list).

Alternatively, you can use the contents of `base.Dockerfile` to fully customize your container's contents or to build it for a container host architecture not supported by the image.

### Installing Node.js

Given JavaScript front-end web client code written for use in conjunction with a Ruby back-end often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.

```jsonc
"args": {
    "VARIANT": "2",
    "NODE_VERSION": "14" // Set to "none" to skip Node.js installation
}
```

### Adding the definition to your folder

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
4. Select the `containers/ruby` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "Hello, Remote Extension Host!" followed by "Hello, Local Extension Host!" in the Debug Console after the program executes.
7. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
