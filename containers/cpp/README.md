# C++

## Summary

*Develop C++ applications on Linux. Includes Debian C++ build tools.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Categories* | Core, Languages |
| *Definition type* | Dockerfile |
| *Published images* | mcr.microsoft.com/vscode/devcontainers/cpp |
| *Available image variants* | debian-11, debian-10, ubuntu-22.04, ubuntu-20.04, ubuntu-18.04 ([full list](https://mcr.microsoft.com/v2/vscode/devcontainers/cpp/tags/list)) |
| *Published image architecture(s)* | x86-64, aarch64/arm64 for `debian-11`, `ubuntu-22.04`, and `ubuntu-18.04` variants |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian, Ubuntu |
| *Languages, platforms* | C++ |

See **[history](history)** for information on the contents of published images.

## Using this definition

While the definition itself works unmodified, you can select the version of Debian or Ubuntu the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "debian-11" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own  `Dockerfile` to one of the following. An example `Dockerfile` is included in this repository.

- `mcr.microsoft.com/vscode/devcontainers/cpp` (latest Debian GA)
- `mcr.microsoft.com/vscode/devcontainers/cpp:debian` (latest Debian GA)
- `mcr.microsoft.com/vscode/devcontainers/cpp:debian-11` (or `bullseye`)
- `mcr.microsoft.com/vscode/devcontainers/cpp:debian-10` (or `buster`)
- `mcr.microsoft.com/vscode/devcontainers/cpp:ubuntu` (latest Ubuntu LTS)
- `mcr.microsoft.com/vscode/devcontainers/cpp:ubuntu-22.04` (or `jammy`)
- `mcr.microsoft.com/vscode/devcontainers/cpp:ubuntu-20.04` (or `focal`)
- `mcr.microsoft.com/vscode/devcontainers/cpp:ubuntu-18.04` (or `bionic`)

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `mcr.microsoft.com/vscode/devcontainers/cpp:0-bullseye`
- `mcr.microsoft.com/vscode/devcontainers/cpp:0.204-bullseye`
- `mcr.microsoft.com/vscode/devcontainers/cpp:0.204.0-bullseye`

However, we only do security patching on the latest [non-breaking, in support](https://github.com/microsoft/vscode-dev-containers/issues/532) versions of images (e.g. `0-debian-11`). You may want to run `apt-get update && apt-get upgrade` in your Dockerfile if you lock to a more specific version to at least pick up OS security updates.

See [history](history) for information on the contents of each version and [here for a complete list of available tags](https://mcr.microsoft.com/v2/vscode/devcontainers/cpp/tags/list).

Alternatively, you can use the contents of `base.Dockerfile` to fully customize your container's contents or to build it for a container host architecture not supported by the image.

Beyond `git`, this image / `Dockerfile` includes `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, a set of common dependencies for development, and [Vcpkg](https://github.com/microsoft/vcpkg) a cross-platform package manager for C++.

### Using Vcpkg
This dev container and its associated image includes a clone of the [`Vcpkg`](https://github.com/microsoft/vcpkg) repo for library packages, and a bootstrapped instance of the [Vcpkg-tool](https://github.com/microsoft/vcpkg-tool) itself.

The minimum version of `cmake` required to install packages is higher than the version available in the main package repositories for Debian (<=11) and Ubuntu (<=21.10).  `Vcpkg` will download a compatible version of `cmake` for its own use if that is the case (on x86_64 architectures), however you can opt to reinstall a different version of `cmake` globally by adding `"REINSTALL_CMAKE_VERSION_FROM_SOURCE: "<VERSION>"` to build args in `.devcontainer/devcontainer.json`. This will install `cmake` from its github releases. For example:

```json
"args": {
   "VARIANT": "debian-11",
   "REINSTALL_CMAKE_VERSION_FROM_SOURCE": "3.21.5"
}
```

Most additional library packages installed using Vcpkg will be downloaded from their [official distribution locations](https://github.com/microsoft/vcpkg#security). To configure Vcpkg in this container to access an alternate registry, more information can be found here: [Registries: Bring your own libraries to vcpkg](https://devblogs.microsoft.com/cppblog/registries-bring-your-own-libraries-to-vcpkg/).

To update the available library packages, pull the latest from the git repository using the following command in the terminal:

```sh
cd "${VCPKG_ROOT}"
git pull --ff-only
```

> Note: Please review the [Vcpkg license details](https://github.com/microsoft/vcpkg#license) to better understand its own license and additional license information pertaining to library packages and supported ports.

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

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/cpp` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "Hello, Remote World!" in the a terminal window after the program finishes executing.
7. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
