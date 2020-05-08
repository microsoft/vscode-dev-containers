# Visual Studio Codespaces (Linux Universal)

## Summary

*Use or extend the large, universal, multi-language development container for Visual Studio Codespaces.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The Visual Studio Codespaces and VS Code teams |
| *Definition type* | Dockerfile |
| *Published image* | mcr.microsoft.com/vscode/devcontainers/universal:linux |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Python, Node.js, JavaScript, TypeScript, C++, Java, C#, .NET Core, PHP, PowerShell |

## Description

While language specific development containers can be useful, in some cases you may want to use more than one in a project without having to set them all up. In other cases you may be looking to create a general "sandbox" container you intend to use with multiple projects or repositories. The large container image generated here (`mcr.microsoft.com/vscode/devcontainers/universal:linux`) includes a number of runtime versions for popular languages lke Python, Node, PHP, Java, C++, and .NET Core/C# - many of which are [inherited from the Oryx build image](https://github.com/microsoft/oryx#supported-platforms) it is based on.

If you use Visual Studio Codespaces, this is the "universal" image that is used by default if no custom Dockerfile or image is specified. If you like what you see but want to make a few additions or changes, you can use a custom Dockerfile to extend it and add whatever you need.

The container includes the `zsh` (and Oh My Zsh!) and `fish` shells that you can opt into using instead of the default `bash`. It also includes [nvm](https://github.com/nvm-sh/nvm) and [nvs](https://github.com/jasongin/nvs) if you need to install a different version of Node.js than those that are in the container by default.

## Using this definition with an existing folder

While the definition itself works unmodified, you can also directly reference pre-built versions of `.devcontainer/Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own  `Dockerfile` to:

` mcr.microsoft.com/vscode/devcontainers/universal:linux`

Alternatively, you can use the contents of the `Dockerfile` to fully customize your container's contents or to build it for a container host architecture not supported by the image.

### Adding the definition to your project

Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use the pre-built image:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the General Purpose Multi-Language Development Container (Visual Studio Codespaces) definition.

3. To use the Dockerfile for this definition (*rather than the pre-built image*):
   1. Clone this repository.
   2. Copy the `.devcontainer` folder from the `containers/codespaces-linux` folder in the cloned repository to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
