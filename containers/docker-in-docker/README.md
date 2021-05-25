# Docker in Docker

## Summary

*Create child containers _inside_ a container, independent from the host's docker instance. Installs Docker extension in the container along with needed CLIs.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | GitHub Codespaces Team |
| *Categories* | Other |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian (though Ubuntu could be used instead) |
| *Languages, platforms* | Any |

## Description

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into your local Docker Desktop instance without affecting your dev container.

In many cases, the best approach to solve this problem is by bind mounting the docker socket, as demonstrated in [/containers/docker-from-docker](../docker-from-docker). This definition demonstrates an alternative technique called "Docker in Docker".

This definition's approach creates pure "child" containers by hosting its own instance of the docker daemon inside this container.  This is compared to the forementioned "docker-_from_-docker" method (sometimes called docker-outside-of-docker) that bind mounts the host's docker socket, creating "sibling" containers to the current container.

> **Note:** If preferred, you can use the related [docker-in-docker/moby-in-moby install script](../../script-library/docs/docker-in-docker.md) in your own existing Dockerfiles instead.

Running "Docker in Docker" requires the parent container to be run as `--privileged`.  This definition also adds a `/usr/local/share/docker-init.sh` ENTRYPOINT script that, spawns the `dockerd` process, so `overrideCommand: false` also needs to be set in `devcontainer.json`. For example:

```json
"runArgs": ["--init", "--privileged"],
"overrideCommand": false
```

## Using this definition

The included `.devcontainer/Dockerfile` can be altered to work with other Debian/Ubuntu-based container images such as `node` or `python`. You'll also need to update `remoteUser` in `.devcontainer/devcontainer.json` in cases where a `vscode` user does not exist in the image you select. For example, to use `mcr.microsoft.com/vscode/devcontainers/javascript-node`, update the `Dockerfile` as follows:

```Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:14
```

...and since the user in this container is `node`, update `devcontainer.json` as follows:

```json
"remoteUser": "node"
```

Beyond that, just follow these steps to use the definition:

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
