# Docker from Docker Compose

## Summary

*Acess your host's Docker install from inside a container when using Docker Compose. Installs Docker extension in the container along with needed CLIs.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code team |
| *Categories* | Other |
| *Definition type* | Docker Compose |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian (though Ubuntu could be used instead) |
| *Languages, platforms* | Any |

> **Note:** There is also a single [Dockerfile](../docker-from-docker) variation of this same definition. If you need to mount folders within the dev container into your own containers, you may find [Docker in Docker](../docker-in-docker) meets your needs better, though with a potential performance penalty.

## Description

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into your local Docker Desktop instance without affecting your dev container.

This example illustrates how you can do this by running CLI commands and using the [Docker VS Code extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) right from inside your dev container.  It installs the Docker extension inside the container so you can use its full feature set with your project.

> **Note:** If preferred, you can use the related [docker/moby install script](../../script-library/docs/docker.md) in your own existing Dockerfiles instead.

The included `.devcontainer/Dockerfile` can be altered to work with other Debian/Ubuntu-based container images such as `node` or `python`. You'll also need to update `remoteUser` in `.devcontainer/devcontainer.json` in cases where a `vscode` user does not exist in the image you select. For example, to use `mcr.microsoft.com/vscode/devcontainers/javascript-node`, update the `Dockerfile` as follows:

```Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:14
```

...and since the user in this container is `node`, update `devcontainer.json` as follows:

```json
"remoteUser": "node"
```

## How it works

While recommend just **using [docker/moby script](../../script-library/docs/docker.md) from the script library** as an easy way to get this running in your own existing container, this section will outline the how you can selectively add this functionality to your own Dockerfile in two parts: enabling access to Docker for the root user, and enabling it for a non-root user.

### Enabling root user access to Docker in the container

You can adapt your own existing development container Dockerfile to support this scenario when running as **root** by following these steps:

1. First, install the Docker CLI in your dev container. From `.devcontainer/Dockerfile`:

    ```Dockerfile
    # Install Docker CE CLI
    RUN apt-get update \
        && apt-get install -y apt-transport-https ca-certificates curl gnupg2 lsb-release \
        && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
        && echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
        && apt-get update \
        && apt-get install -y docker-ce-cli \

    # Install Docker Compose
    RUN export LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")') \
        && curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
        && chmod +x /usr/local/bin/docker-compose
    ```

2. Then just forward the Docker socket by mounting it in the container in your Docker Compose config. From `.devcontainer/docker-compose.yml`:

    ```yaml
    init: true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    ```

3. Press <kbd>F1</kbd> and run **Remote-Containers: Rebuild Container** so the changes take effect.

### Enabling non-root access to Docker in the container

This can be a bit trickier than it might first seem if you're looking to ensure things run locally on macOS, Windows, and Linux as well as in Codespaces. The **[docker script](../../script-library/docs/docker.md)** used in this container **automatically detects the right thing** to do to enable this scenario, but it uses the following two approaches to accomplish it.

#### Adding the user to a Docker group

In some environments like Codespaces, this is relatively simple to achieve if the Docker socket already has a group other than root on it. To see if this is the case, open a terminal in VS Code when connected to the container to check:

```bash
stat -c '%g' /var/run/docker.sock
```

If you get a number other than `0`, you can simply add your non-root user to right user group. To do so:

1. As before, follow [the instructions in the Remote - Containers documentation](https://aka.ms/vscode-remote/containers/non-root) to create a non-root user with sudo access if you do not already have one (though sudo is not required if you start the container itself as root as shown here).

2. Follow the [directions in the previous section](#enabling-root-user-access-to-docker-in-the-container) to install the Docker CLI.

3. Update your Dockerfile as follows to create a group with the right group ID and be sure the user is in it:

    ```Dockerfile
    ARG NONROOT_USER=vscode

    RUN echo "#!/bin/sh\n\
        sudoIf() { if [ \"\$(id -u)\" -ne 0 ]; then sudo \"\$@\"; else \"\$@\"; fi }\n\
        SOCKET_GID=\$(stat -c '%g' /var/run/docker.sock) \n\
        if [ \"${SOCKET_GID}\" != '0' ]; then\n\
            if [ \"\$(cat /etc/group | grep :\${SOCKET_GID}:)\" = '' ]; then sudoIf groupadd --gid \${SOCKET_GID} docker-host; fi \n\
            if [ \"\$(id ${NONROOT_USER} | grep -E \"groups=.*(=|,)\${SOCKET_GID}\(\")\" = '' ]; then sudoIf usermod -aG \${SOCKET_GID} ${NONROOT_USER}; fi\n\
        fi\n\
        exec \"\$@\"" > /usr/local/share/docker-init.sh \
        && chmod +x /usr/local/share/docker-init.sh

    # Setting the ENTRYPOINT to docker-init.sh will configure non-root access 
    # to the Docker socket. The script will also execute CMD as needed.
    ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
    CMD [ "sleep", "infinity" ]
    ```

4. Press <kbd>F1</kbd> and run **Remote-Containers: Rebuild Container** so the changes take effect.

#### Final fallback: socat

However, if the host's socket is owned by the root user and root group (`0`), you'll need to either change the group on the socket on the host or use `socat` to proxy the Docker socket without affecting its permissions. The `socat` option can be safer than updating the permissions of the host socket itself since this would apply to all containers. You can also alias `docker` to be `sudo docker` in a `.bashrc` file, but this does not work in cases where the Docker socket is accessed directly.

Follow these directions to set up non-root access using `socat`:

1. Follow [the instructions in the Remote - Containers documentation](https://aka.ms/vscode-remote/containers/non-root) to create a non-root user with sudo access if you do not already have one.

2. Follow the [directions in the previous section](#enabling-root-user-access-to-docker-in-the-container) to install the Docker CLI.

3. Update your `docker-compose.yml` to mount the Docker socket to `docker-host.sock` in the container:

    ```yaml
    init: true
    volumes:
      - /var/run/docker.sock:/var/run/docker-host.sock
    ```

    While technically optional, `init: true` enables an [init process](https://docs.docker.com/engine/reference/run/#specify-an-init-process) to properly handle signals and ensure [Zombie Processes](https://en.wikipedia.org/wiki/Zombie_process) are cleaned up.

4. Next, add the following to your `Dockerfile` to wire up `socat`:

    ```Dockerfile
    ARG NONROOT_USER=vscode

    # Default to root only access to the Docker socket, set up non-root init script
    RUN touch /var/run/docker-host.sock \
        && ln -s /var/run/docker-host.sock /var/run/docker.sock \
        && apt-get update \
        && apt-get -y install socat

    # Create docker-init.sh to spin up socat
    RUN echo "#!/bin/sh\n\
        sudoIf() { if [ \"\$(id -u)\" -ne 0 ]; then sudo \"\$@\"; else \"\$@\"; fi }\n\
        sudoIf rm -rf /var/run/docker.sock\n\
        ((sudoIf socat UNIX-LISTEN:/var/run/docker.sock,fork,mode=660,user=${NONROOT_USER} UNIX-CONNECT:/var/run/docker-host.sock) 2>&1 >> /tmp/vscr-docker-from-docker.log) & > /dev/null\n\
        \"\$@\"" >> /usr/local/share/docker-init.sh \
        && chmod +x /usr/local/share/docker-init.sh

    # VS Code overrides ENTRYPOINT and CMD when executing `docker run` by default.
    # Setting the ENTRYPOINT to docker-init.sh will configure non-root access to
    # the Docker socket if "overrideCommand": false is set in devcontainer.json.
    # The script will also execute CMD if you need to alter startup behaviors.
    ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
    CMD [ "sleep", "infinity" ]
    ```

5. Finally, update your `devcontainer.json` to use the non-root user:

    ```json
    "remoteUser": "vscode"
    ```

6. Press <kbd>F1</kbd> and run **Remote-Containers: Rebuild Container** so the changes take effect.

That's it!

## Using bind mounts when working with Docker inside the container

> **Note:** If you need to mount folders within the dev container into your own containers using docker-from-docker, so you may find [Docker in Docker](../docker-in-docker) meets your needs better in some cases (despite a potential performance penalty).

In some cases, you may want to be able to mount the local workspace folder into a container you create while running from inside the dev container (e.g. using `-v` from the Docker CLI). The issue is that, with "Docker from Docker", containers are always created on the host. So, when you bind mount a folder into any container, you'll need to use the **host**'s paths.

In GitHub Codespaces, the workspace folder is **available in the same place on the host as it is in the container,** so you can bind workspace contents as you would normally.

However, for Remote - Containers, this is typically not the case. A simple way to work around this is to put `${localWorkspaceFolder}` in an environment variable that you then use when doing bind mounts inside the container.

Add the following to `devcontainer.json`:

```json
"remoteEnv": { "LOCAL_WORKSPACE_FOLDER": "${localWorkspaceFolder}" }
```

Then reference the env var when running Docker commands from the terminal inside the container.

```bash
docker run -it --rm -v "${LOCAL_WORKSPACE_FOLDER//\\/\/}:/workspace" debian bash
```

## Using this definition

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
