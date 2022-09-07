**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `docker-from-docker` Feature to [devcontainers/features/src/docker-from-docker](https://github.com/devcontainers/features/tree/main/src/docker-from-docker).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Docker-from-Docker Install Script

> Need to mount files from inside your container into new ones you create? You may need to use [docker-in-docker](./docker-in-docker.md) instead.

*Adds the Docker CLI to a container along with a script to enable using a forwarded Docker socket within a container to run Docker commands.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, CentOS/RHEL 7+ (community supported) and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams, [@smankoo](https://github.com/smankoo) (`docker-redhat.sh`)

> **Note:** `docker-redhat.sh` is community supported.

## Syntax

```text
./docker-debian.sh [Non-root access flag] [Source socket] [Target socket] [Non-root user] [Use Moby] [Docker / Moby version]  [Major version for docker-compose]
./docker-redhat.sh [Non-root access flag] [Source socket] [Target socket] [Non-root user]
```

Or as a feature (Debian/Ubuntu only):

```json
"features": {
    "docker-from-docker": {
        "version": "latest",
        "moby": true,
        "dockerDashComposeVersion": "v1"
    }
}
```

|Argument|Feature option| Default | Description |
|--------|--------------|---------|-------------|
|Non-root access flag| | `true`| Flag (`true`/`false`) that specifies whether a non-root user should be granted access to the Docker socket.|
|Source socket| | `/var/run/docker-host.sock`| Location that the host's Docker socket has been mounted in the container.|
|Target socket| | `/var/run/docker.sock`| Location within the container that the Docker CLI will expect to find the Docker socket with permissions that allow the non-root user to access it.|
|Non-root user| | `automatic`| Specifies a user in the container other than root that will be using the desktop. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
|Use Moby| `moby` | `true`| Specifies that a build of the open source [Moby CLI](https://github.com/moby/moby/tree/master/cli) should be used instead of the Docker CLI distribution of it. |
| Docker / Moby version | `version` | `latest` |  Docker/Moby Engine version or `latest`. Partial version numbers allowed. Availability can vary by OS version. |
| Major version for docker-compose | `dockerDashComposeVersion` | `v1` | Updates `docker-compose` to either Docker Compose v1 or v2 ([learn more](https://docs.docker.com/compose/cli-command/#transitioning-to-ga-for-compose-v2)). |

## Usage

### Feature use

You can use this script for your primary dev container by adding it to the `features` property in `devcontainer.json`.

```json
"features": {
    "docker-from-docker": {
        "version": "latest",
        "moby": true
    }
}
```

**[Optional]** You may also want to enable the [tini init process](https://docs.docker.com/engine/reference/run/#specify-an-init-process) to handle signals and clean up [Zombie processes](https://en.wikipedia.org/wiki/Zombie_process) if you do not have an alternative set up. To enable it, add the following to `devcontainer.json` if you are referencing an image or Dockerfile:

```json
"runArgs": ["--init"]
```

Or when using Docker Compose:

```yaml
services:
  your-service-here:
    # ...
    init: true
    # ...
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

See the [`docker-from-docker`](../../containers/docker-from-docker) and [`docker-from-docker-compose`](../../containers/docker-from-docker-compose) definition for a complete working example. However, here are the general steps to use the script:

1. Add [`docker-debian.sh`](../docker-debian.sh) or [`docker-redhat.sh`](../docker-redhat.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/docker-debian.sh /tmp/library-scripts/
    ENV DOCKER_BUILDKIT=1
    RUN apt-get update && bash /tmp/library-scripts/docker-debian.sh
    ENTRYPOINT ["/usr/local/share/docker-init.sh"]
    CMD ["sleep", "infinity"]
    ```

    For CentOS/RedHat, simply replace the `RUN` above with:

    ```Dockerfile
    RUN bash /tmp/library-scripts/docker-redhat.sh
    ```

    Note that the `ENTRYPOINT` script can be chained with another script by adding it to the array after `docker-init.sh`.

3. And the following to `.devcontainer/devcontainer.json` if you are referencing an image or Dockerfile:

    ```json
    "runArgs": ["--init"],
    "mounts": [ "source=/var/run/docker.sock,target=/var/run/docker-host.sock,type=bind" ],
    "overrideCommand": false
    ```

    Or if you are referencing a Docker Compose file, add this to your `docker-compose.yml` file instead:
    
    ```yaml
    your-service-name-here:
      init: true
      volumes:
        - /var/run/docker.sock:/var/run/docker-host.sock
    ```

    While technically optional, `--init` enables the [tini init process](https://docs.docker.com/engine/reference/run/#specify-an-init-process) to properly handle signals and ensure [Zombie Processes](https://en.wikipedia.org/wiki/Zombie_process) are cleaned up.

4. If you are running the container as something other than root (either via `USER` in your Dockerfile or `containerUser`), you'll need to ensure that the user has `sudo` access. (If you run the container as root and just reference the user in `remoteUser` you will not have this problem, so this is recommended instead.) The [`debian-common.sh`](common.md) script can do this for you, or you [set one up yourself](https://aka.ms/vscode-remote/containers/non-root).

### Supporting bind mounts from the workspace folder

A common question that comes up is how you can use `bind` mounts from the Docker CLI from within the Codespace itself (e.g. via `-v`). The trick is that, since you're actually using Docker sitting outside of the container, the paths will be different than those in the container. You need to use the **host**'s paths instead.

> **Note:** The docker-from-docker approach does not currently enable bind mounting locations outside of the workspace folder.

#### GitHub Codespaces

In GitHub Codespaces, the workspace folder should work with bind mounts by default, so no further action is required.

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

> **Note:** There is no `${localWorkspaceFolder}` when using the **Clone Repository in Container Volume** command ([info](https://github.com/microsoft/vscode-remote-release/issues/6160#issuecomment-1014701007)).
