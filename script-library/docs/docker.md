# Docker-from-Docker Install Script

*Adds the Docker CLI to a container along with a script to enable using a forwarded Docker socket within a container to run Docker commands.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

## Syntax

```text
./docker-debian.sh [Non-root access flag] [Source socket] [Target socket] [Non-root user]
./docker-redhat.sh [Non-root access flag] [Source socket] [Target socket] [Non-root user]
```

|Argument|Default|Description|
|--------|-------|-----------|
|Non-root access flag|`true`| Flag (`true`/`false`) that specifies whether a non-root user should be granted access to the Docker socket.|
|Source socket|`/var/run/docker-host.sock`| Location that the host's Docker socket has been mounted in the container.|
|Target socket|`/var/run/docker.sock`| Location within the container that the Docker CLI will expect to find the Docker socket with permissions that allow the non-root user to access it.|
|Non-root user|`automatic`| Specifies a user in the container other than root that will be using the desktop. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |

## Usage

See the [`docker-from-docker`](../../containers/docker-from-docker) and [`docker-from-docker-compose`](....//containers/docker-from-docker) definition for a complete working example. However, here are the general steps to use the script:

1. Add [`docker-debian.sh`](../docker-debian.sh) or [`docker-redhat.sh`](../docker-redhat.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/docker-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/docker-debian.sh
    ENTRYPOINT ["/usr/local/share/docker-init.sh"]
    CMD ["sleep", "infinity"]
    ```

    For CentOS/RedHat, simply replace the `RUN` above with:

    ```Dockerfile
    RUN bash /tmp/library-scripts/docker-redhat.sh
    ```

    Note that the `ENTRYPOINT` script can be chained with another script by adding it to the array after `docker-init.sh`.

3. And the following to `.devcontainer/devcontainer.json`:

    ```json
    "runArgs": ["--init"],
    "mounts": [ "source=/var/run/docker.sock,target=/var/run/docker-host.sock,type=bind" ],
    "overrideCommand": false
    ```

    While technically optional, `--init` enables an [init process](https://docs.docker.com/engine/reference/run/#specify-an-init-process) to properly handle signals and ensure [Zombie Processes](https://en.wikipedia.org/wiki/Zombie_process) are cleaned up.

4. If you are running the container as something other than root (either via `USER` in your Dockerfile or `containerUser`), you'll need to ensure that the user has `sudo` access. (If you run the container as root and just reference the user in `remoteUser` you will not have this problem, so this is recommended instead.) The [`debian-common.sh`](common.md) script can do this for you, or you [set one up yourself](https://aka.ms/vscode-remote/containers/non-root).

### Supporting bind mounts from the workspace folder

A common question that comes up is how you can use `bind` mounts from the Docker CLI from within the Codespace itself (e.g. via `-v`). The trick is that, since you're acutally using Docker sitting outside of the container, the paths will be different than those in the container. You need to use the **host**'s paths instead.

> **Note:** The docker-from-docker approach does not currently enable bind mounting locations outside of the workspace folder.

#### Remote - Containers

A simple way to do this is to put `${localWorkspaceFolder}` in an environment variable that you then use when doing bind mounts inside the container.

Add the following to `devcontainer.json`:

```json
"remoteEnv": { "LOCAL_WORKSPACE_FOLDER": "${localWorkspaceFolder}" }
```

Then reference the env var when running Docker commands from the terminal inside the container.

```bash
docker run -it --rm -v ${LOCAL_WORKSPACE_FOLDER}:/workspace debian bash
```

#### GitHub Codespaces

In GitHub Codespaces, you can make this a bit more transparent so that just bind mounting the workspace folder functions without problem.

> **Note:** This is a short term workaround that should be resolved in the core GitHub Codespaces service over time.

Create file called `.devcontainer/fix-bind-mount.sh` in your codespace with the following contents:

```bash
#!/bin/bash
if [ "${CODESPACES}" != "true" ]; then
    echo 'Not in a codespace. Aborting.'
    exit 0
fi

WORKSPACE_PATH_IN_CONTAINER=${1:-"$HOME/workspace"}
shift
WORKSPACE_PATH_ON_HOST=${2:-"/var/lib/docker/vsonlinemount/workspace"}
shift
VM_CONTAINER_WORKSPACE_PATH=/vm-host/$WORKSPACE_PATH_IN_CONTAINER
VM_CONTAINER_WORKSPACE_BASE_FOLDER=$(dirname $VM_CONTAINER_WORKSPACE_PATH)
VM_HOST_WORKSPACE_PATH=/vm-host/$WORKSPACE_PATH_ON_HOST

echo -e "Workspace path in container: ${WORKSPACE_PATH_IN_CONTAINER}\nWorkspace path on host: ${WORKSPACE_PATH_ON_HOST}"
docker run --rm -v /:/vm-host alpine sh -c "\
    if [ -d "${VM_CONTAINER_WORKSPACE_PATH}" ]; then echo \"${WORKSPACE_PATH_IN_CONTAINER} already exists on host. Aborting.\" && return 0; fi
    apk add coreutils > /dev/null \
    && mkdir -p $VM_CONTAINER_WORKSPACE_BASE_FOLDER \
    && cd $VM_CONTAINER_WORKSPACE_BASE_FOLDER \
    && ln -s \$(realpath --relative-to='.' $VM_HOST_WORKSPACE_PATH) .\
    && echo 'Symlink created!'"
```

Each time you **start** your codespace, run the script:

```bash
bash .devcontainer/fix-bind-mount.sh
```

That's it!
