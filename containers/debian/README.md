# Debian

## Summary

*Simple Debian container with Git installed.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Definition type* | Dockerfile |
| *Published images* | mcr.microsoft.com/vscode/devcontainers/base:debian |
| *Available image variants* |   mcr.microsoft.com/vscode/devcontainers/base:stretch <br /> mcr.microsoft.com/vscode/devcontainers/base:buster |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Any |

## Using this definition with an existing folder

While the definition itself works unmodified, you can select the version of Debian the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```
"args": { "VARIANT": "stretch" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own  `Dockerfile` to one of the following. An example `Dockerfile` is included in this repository.

- `mcr.microsoft.com/vscode/devcontainers/base:debian` (latest)
- `mcr.microsoft.com/vscode/devcontainers/base:buster` (or `debian-10`)
- `mcr.microsoft.com/vscode/devcontainers/base:stretch` (or `debian-9`)

Version specific tags tied to [releases in this repository](https://github.com/microsoft/vscode-dev-containers/releases) are also available.

- `mcr.microsoft.com/vscode/devcontainers/base:0-buster`
- `mcr.microsoft.com/vscode/devcontainers/base:0.123-buster`
- `mcr.microsoft.com/vscode/devcontainers/base:0.123.0-buster`

Alternatively, you can use the contents of `base.Dockerfile` to fully customize your container's contents or to build it for a container host architecture not supported by the image.

Beyond `git`, this image / `Dockerfile` includes `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

### Adding the definition to your project

Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use the pre-built image:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Debian definition.

3. To use the Dockerfile for this definition (*rather than the pre-built image*):
   1. Clone this repository.
   2. Copy the contents of `containers/debian/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/debian` folder.
5. Press <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>\`</kbd> and type the following command to verify installation: `apt-get update && apt-get install -y lsb-release && git --version && lsb_release -a`
6. After lsb_release installs, you should see the Git version and details about the version of Linux in the container.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE)
