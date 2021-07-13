# Common Utility and Non-Root User Install Script

*Installs a set of common command line utilities, Oh My Zsh!, and sets up a non-root user.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, Alpine 3.9+, CentOS/RHEL 7+ (community supported) and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./common-debian.sh [Install zsh flag] [Non-root user] [User UID] [User GID] [Upgrade packages flag] [Install Oh My Zsh! flag]
./common-redhat.sh [Install zsh flag] [Non-root user] [User UID] [User GID] [Upgrade packages flag] [Install Oh My Zsh! flag]
./common-alpine.sh [Install zsh flag] [Non-root user] [User UID] [User GID] [Install Oh My Zsh! flag]
```

> **Note:** `common-redhat.sh` is community supported.

|Argument|Default|Description|
|--------|-------|-----------|
|Install zsh flag|`true`| A `true`/`false` flag that indicates whether zsh should be installed. |
|Non-root user|`automatic`| Specifies a user in the container other than root that should be created or modified. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. A value of `none` will skip this step. |
|User UID|`automatic`| A specific UID (e.g. `1000`) for the user that will be created modified. A value of `automatic` will pick a free one if the user is created. |
|User GID|`automatic`| A specific GID (e.g. `1000`) for the user's group that will be created modified. A value of `automatic` will pick a free one if the group is created. |
| Upgrade packages flag | `true` | A `true`/`false` flag that indicates whether packages should be upgraded to the latest for the distro. |
| Install Oh My Zsh! flag | `true` | A `true`/`false` flag that indicates whether Oh My Zsh! should be installed. |

> **Note:** Previous versions of this script also installed Oh My Bash! but this has been dropped in favor of a simplified, default PS1 since it conflicted with common user configuration. A stub has been added so those that may have referenced it in places like their dotfiles are informed of the change and how to add it back if needed.

## Usage

**Ubuntu / Debian:**

1. Add [`common-debian.sh`](../common-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/common-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/common-debian.sh
    ```

**RedHat:**

1. Add [`common-redhat.sh`](../common-redhat.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/common-redhat.sh /tmp/library-scripts/
    RUN bash /tmp/library-scripts/common-redhat.sh

**Alpine:**

1. Add [`common-alpine.sh`](../common-alpine.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/common-alpine.sh /tmp/library-scripts/
    RUN ash /tmp/library-scripts/common-alpine.sh

### Common entrypoint

This script also includes a common container entrypoint that can make it easier to to start things automatically whenever the container starts rather than relying on `devcontainer.json`'s `postStartCommand` property (which cannot be baked into a container image). Other script-library scripts are already set up to use it where applicable. 

It also will automatically look for common existing entrypoint locations like `/docker-entrypoint.sh` and `/usr/local/bin/docker-entrypoint.sh` and wire them in so you do not need to worry about them.

To use it:

1. Update your Dockerfile to include the entrypoint and a command that keeps the container running:

    ```Dockerfile
    ENTRYPOINT ["/usr/local/bin/devcontainer-entrypoint"]
    CMD ["sleep", "infinity"]
    ```

2. [Optional] Copy your own shell script into the right location and make it executable.

    ```Dockerfile
    COPY your-script-name-here.sh /usr/local/etc/devcontainer-entrypoint.d/
    RUN chmod +x /usr/local/etc/devcontainer-entrypoint.d/*.sh
    ```

3. Update `devcontainer.json` to ensure the entrypoint is used:

    ```json
    "overrideCommand": false
    ```

That's it!
