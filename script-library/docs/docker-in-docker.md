# Docker-in-Docker Install Script

> Interested in running docker commands from inside a container?  Chances are the [Docker-from-Docker](./docker.md) technique may suit your needs better.

*Create child containers _inside_ a container, independent from the host's docker instance. Installs Docker extension in the container along with needed CLIs.* 

**OS support**: Debian 9+, Ubuntu 20.04+, and downstream distros.

## Syntax

```text
./docker-in-docker-debian.sh [enable non-root docker access flag] [non-root user] [use moby]
```

|Argument|Default|Description|
|--------|-------|-----------|
|Non-root access flag|`true`| Flag (`true`/`false`) that specifies whether a non-root user should be granted access to Docker.|
|Non-root user|`automatic`| Specifies a user in the container other than root that will be using the desktop. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
|Use Moby|`true`| Specifies that a build of the open source [Moby CLI](https://github.com/moby/moby/tree/master/cli) should be used instead of the Docker CLI distribution of it. |

## Usage

See the [`docker-in-docker`](../../containers/docker-in-docker) definition for a complete working example. However, here are the general steps to use the script:

1. Add [`docker-debian.sh`](../docker-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/*.sh /tmp/library-scripts/
    RUN apt-get update && /bin/bash /tmp/library-scripts/docker-in-docker-debian.sh
    ENTRYPOINT ["/usr/local/share/docker-init.sh"]
    VOLUME [ "/var/lib/docker" ]
    CMD ["sleep", "infinity"]
    ```

Note that the `ENTRYPOINT` script can be chained with another script by adding it to the array after `docker-init.sh`.

3. And the following to `.devcontainer/devcontainer.json`:

    ```json
    "runArgs": ["--init", "--privileged"],
    "overrideCommand": false
    ```

    While technically optional, `--init` enables an [init process](https://docs.docker.com/engine/reference/run/#specify-an-init-process) to properly handle signals and ensure [Zombie Processes](https://en.wikipedia.org/wiki/Zombie_process) are cleaned up.

4. If you are running the container as something other than root (either via `USER` in your Dockerfile or `containerUser`), you'll need to ensure that the user has `sudo` access. (If you run the container as root and just reference the user in `remoteUser` you will not have this problem, so this is recommended instead.) The [`debian-common.sh`](common.md) script can do this for you, or you [set one up yourself](https://aka.ms/vscode-remote/containers/non-root).

## Resources

This docker-in-docker definition is roughly based on the [official docker-in-docker wrapper script](https://github.com/moby/moby/blob/master/hack/dind).  The original blog post on this concept can be [found here](https://blog.docker.com/2013/09/docker-can-now-run-within-docker/).