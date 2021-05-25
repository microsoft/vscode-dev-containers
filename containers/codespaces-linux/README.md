# GitHub Codespaces (Default Linux Universal)

## Summary

*Use or extend the new Ubuntu-based default, large, multi-language universal container for GitHub Codespaces.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The GitHub Codespaces team |
| *Categories* | Services, GitHub |
| *Definition type* | Dockerfile |
| *Published image* | mcr.microsoft.com/vscode/devcontainers/universal:linux<br />mcr.microsoft.com/vscode/devcontainers/universal:focal |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Ubuntu |
| *Languages, platforms* | Python, Node.js, JavaScript, TypeScript, C++, Java, C#, F#, .NET Core, PHP, PowerShell, Go, Ruby, Rust |

See **[history](history)** for information on the contents of published images.

## Description

While language specific development containers can be useful, in some cases you may want to use more than one in a project without having to set them all up. In other cases you may be looking to create a general "sandbox" container you intend to use with multiple projects or repositories. The large container image generated here (`mcr.microsoft.com/vscode/devcontainers/universal:linux`) includes a number of runtime versions for popular languages lke Python, Node, PHP, Java, Go, C++, Ruby, Go, Rust and .NET Core/C# - many of which are [inherited from the Oryx build image](https://github.com/microsoft/oryx#supported-platforms) it is based on.

If you use GitHub Codespaces, this is the "universal" image that is used by default if no custom Dockerfile or image is specified. If you like what you see but want to make a few additions or changes, you can use a custom Dockerfile to extend it and add whatever you need.

The container includes the `zsh` (and Oh My Zsh!) and `fish` shells that you can opt into using instead of the default `bash`. It also includes [nvm](https://github.com/nvm-sh/nvm), [rvm](https://rvm.io/), [rbenv](https://github.com/rbenv/rbenv), and [SDKMAN!](https://sdkman.io/) if you need to install a different version Node, Ruby, or Java tools than the container defaults. You can also set things up to access the container [via SSH](#accessing-the-container-using-ssh-scp-or-sshfs).

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. However, **note that only the most recent image is pre-cached in Codespaces**. For example:

- `mcr.microsoft.com/vscode/devcontainers/universal:1-focal`
- `mcr.microsoft.com/vscode/devcontainers/universal:1.3-focal`
- `mcr.microsoft.com/vscode/devcontainers/universal:1.3.3-focal`

See [history](history) for information on the contents of each version and [here for a complete list of available tags](https://mcr.microsoft.com/v2/vscode/devcontainers/universal/tags/list).

## Accessing the container using SSH, SCP, or SSHFS

This container also includes a running SSH server that you can use to access the contents if needed. To use it:

1. Create a codespace in [GitHub Codespaces](https://github.com/features/codespaces) (this is the default image) or open this container in Remote - Containers.

2. If you created a codespace using a web browser in GitHub Codespaces, setup the [VS Code extension and connect to it from your local VS Code](https://docs.github.com/en/github/developing-online-with-codespaces/connecting-to-your-codespace-from-visual-studio-code).

3. When connected to the codespace, use a terminal in VS Code to set a password when connecting:

   ```bash
   sudo passwd $(whoami)
   ```

4. Press <kbd>F1</kbd> and select **Forward a Port...** and enter port `2222`.

5. You're all set! You can connect using SSH as follows:

   ```bash
   ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null codespace@localhost
   ```

   The `-o` arguments are not required, but will avoid errors about the "known host" signature changing when doing this from multiple codespaces.

6. Enter the password you set in step 3.

That's it! Use similar arguments to those in step 5 when executing `scp` or configuring SSHFS.

## Using this definition

While the definition itself works unmodified, you can also directly reference pre-built versions of `.devcontainer/Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own  `Dockerfile` to:

`mcr.microsoft.com/vscode/devcontainers/universal:linux`

Alternatively, you can use the contents of the `Dockerfile` to fully customize your container's contents or to build it for a container host architecture not supported by the image.

### Adding the definition to a project or codespace

Given its size, we do not recommend extending this image. However, you can add it to a project or codespace as follows:

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. To use the pre-built image:
   1. Start VS Code and open your project folder or connect to a codespace.
   2. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.
   3. Select this definition.

3. To build a custom version of the image instead (which can take upwards of 30 mins):
   1. Clone this repository locally.
   2. Start VS Code and open your project folder or connect to a codespace.
   3. Use your local operating system's file explorer to drag-and-drop the locally cloned copy of the `.devcontainer` folder for this definition into the VS Code file explorer for your opened project or codespace.
   4. Update `.devcontainer/devcontainer.json` to reference `"dockerfile": "base.Dockerfile"`.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.n.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
