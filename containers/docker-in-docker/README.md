# Docker in Docker

## Summary

*Create child containers _inside_ a container, independent from the host's docker instance. Installs Docker extension in the container along with needed CLIs.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | GitHub Codespaces Team |
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

## Using this definition with an existing folder

The included `.devcontainer/Dockerfile` can be altered to work with other Debian/Ubuntu-based container images such as `node` or `python`. You'll also need to update `remoteUser` in `.devcontainer/devcontainer.json` in cases where a `vscode` user does not exist in the image you select. For example, to use `mcr.microsoft.com/vscode/devcontainers/javascript-node`, update the `Dockerfile` as follows:

```Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:14
```

...and since the user in this container is `node`, update `devcontainer.json` as follows:

```json
"remoteUser": "node"
```

Beyond that, just follow these steps to use the definition:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Docker from Docker Compose definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/docker-from-docker-compose/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
