**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `docker-in-docker` Feature to [devcontainers/features/src/docker-in-docker](https://github.com/devcontainers/features/tree/main/src/docker-in-docker).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Docker-in-Docker Install Script

> Interested in running docker commands from inside a container?  The [Docker-from-Docker](./docker.md) technique may suit your needs better.

*Create child containers _inside_ a container, independent from the host's docker instance. Installs Docker extension in the container along with needed CLIs.* 

**Script status:** Stable

**OS support**: Debian 9+, Ubuntu 20.04+, and downstream distros.

> **Note:** Your host chip architecture needs to match the your container image architecture for this script to function. Cross-architecture emulation will not work.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./docker-in-docker-debian.sh [Enable non-root docker access flag] [Non-root user] [Use Moby] [Docker / Moby Version] [Major version for docker-compose]
```

Or as a feature:

```json
"features": {
    "docker-in-docker": {
        "version": "latest",
        "moby": true,
        "dockerDashComposeVersion": "v1"
    }
}
```

|Argument| Feature option |Default|Description|
|--------|----------------|-------|-----------|
|Non-root access flag| | `true`| Flag (`true`/`false`) that specifies whether a non-root user should be granted access to Docker.|
|Non-root user| | `automatic`| Specifies a user in the container other than root that will be using the desktop. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
|Use Moby | `moby`|`true` | Specifies that a build of the open source [Moby CLI](https://github.com/moby/moby/tree/master/cli) should be used instead of the Docker CLI distribution of it. |
| Docker / Moby version | `version` | `latest` |  Docker/Moby Engine version or `latest`. Partial version numbers allowed. Availability can vary by OS version. |
| Major version for docker-compose | `dockerDashComposeVersion` | `v1` | Updates `docker-compose` to either Docker Compose v1 or v2 ([learn more](https://docs.docker.com/compose/cli-command/#transitioning-to-ga-for-compose-v2)). |


## Usage

### Feature use

You can use this script for your primary dev container by adding it to the `features` property in `devcontainer.json`.

```json
"features": {
    "docker-in-docker": {
        "version": "latest",
        "moby": true,
        "dockerDashComposeVersion": "v1"
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

See the [`docker-in-docker`](../../containers/docker-in-docker) definition for a complete working example. However, here are the general steps to use the script:

1. Add [`docker-in-docker-debian.sh`](../docker-in-docker-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    # If "context" is set to ".." in devcontainer.json, use .devcontainer/library-scripts/*.sh
    COPY library-scripts/*.sh /tmp/library-scripts/

    ENV DOCKER_BUILDKIT=1
    RUN apt-get update && /bin/bash /tmp/library-scripts/docker-in-docker-debian.sh
    ENTRYPOINT ["/usr/local/share/docker-init.sh"]
    VOLUME [ "/var/lib/docker" ]
    CMD ["sleep", "infinity"]
    ```

    Note that the `ENTRYPOINT` script can be chained with another script by adding it to the array after `docker-init.sh`.

3. And the following to `.devcontainer/devcontainer.json` if you are referencing an image or Dockerfile:

    ```json
    "runArgs": ["--init", "--privileged"],
    "overrideCommand": false
    ```

    Or if you are referencing a Docker Compose file, add this to your `docker-compose.yml` file instead:

    ```yaml
    your-service-name-here:
      init: true 
      privileged: true
      # ...
    ```

    The `dind-var-lib-docker` volume mount is optional but will ensure that containers / volumes you create within the dev container survive a rebuild. You should update `dind-var-lib-docker` with a unique name for your container to avoid corruption when multiple containers write to it at the same time.

    While technically optional, `--init` enables the [tini init process](https://docs.docker.com/engine/reference/run/#specify-an-init-process) to properly handle signals and ensure [Zombie Processes](https://en.wikipedia.org/wiki/Zombie_process) are cleaned up. 

4. If you want any containers or volumes you create inside the container to survive it being deleted, you can use a "named volume". And the following to `.devcontainer/devcontainer.json` if you are referencing an image or Dockerfile replacing `dind-var-lib-docker` with a unique name for your container:

    ```json
    "mounts": ["source=dind-var-lib-docker,target=/var/lib/docker,type=volume"]
    ```

    Or if you are referencing a Docker Compose file, add this to your `docker-compose.yml` file instead:

    ```yaml
    your-service-name-here:
      # ...
      volumes:
        - dind-var-lib-docker:/var/lib/docker
      # ...
    ```

5. If you are running the container as something other than root (either via `USER` in your Dockerfile or `containerUser`), you'll need to ensure that the user has `sudo` access. (If you run the container as root and just reference the user in `remoteUser` you will not have this problem, so this is recommended instead.) The [`debian-common.sh`](common.md) script can do this for you, or you [set one up yourself](https://aka.ms/vscode-remote/containers/non-root).

## Resources

This docker-in-docker definition is roughly based on the [official docker-in-docker wrapper script](https://github.com/moby/moby/blob/master/hack/dind).  The original blog post on this concept can be [found here](https://blog.docker.com/2013/09/docker-can-now-run-within-docker/).
