**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `common-utils` Feature to [devcontainers/features/src/common-utils](https://github.com/devcontainers/features/tree/main/src/common-utils).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Common Utility and Non-Root User Install Script

*Installs a set of common command line utilities, Oh My Zsh!, and sets up a non-root user.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, Alpine 3.9+, CentOS/RHEL 7+ (community supported) and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./common-debian.sh [Install zsh flag] [Non-root user] [User UID] [User GID] [Upgrade packages flag] [Install Oh My Zsh! flag] [Non-free packages flag]
./common-redhat.sh [Install zsh flag] [Non-root user] [User UID] [User GID] [Upgrade packages flag] [Install Oh My Zsh! flag]
./common-alpine.sh [Install zsh flag] [Non-root user] [User UID] [User GID] [Install Oh My Zsh! flag]
```

Or as a feature (Debian/Ubuntu only):

```json
"features": {
    "common": {
        "username": "automatic",
        "uid": "automatic",
        "gid": "automatic",
        "installZsh": true,
        "installOhMyZsh": true,
        "upgradePackages": true,
        "nonFreePackages": false
    }
}
```



> **Note:** `common-redhat.sh` is community supported.

|Argument| Feature option |Default|Description|
|--------|----------------|-------|-----------|
|Install zsh flag| `installZsh` | `true`| A `true`/`false` flag that indicates whether zsh should be installed. |
|Non-root user| `username` |`automatic`| Specifies a user in the container other than root that should be created or modified. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. A value of `none` will skip this step. |
|User UID| `uid` |`automatic`| A specific UID (e.g. `1000`) for the user that will be created modified. A value of `automatic` will pick a free one if the user is created. |
|User GID| `gid` | `automatic`| A specific GID (e.g. `1000`) for the user's group that will be created modified. A value of `automatic` will pick a free one if the group is created. |
| Upgrade packages flag | `upgradePackages` | `true` | A `true`/`false` flag that indicates whether packages should be upgraded to the latest for the distro. |
| Install Oh My Zsh! flag | `installOhMyZsh` | `true` | A `true`/`false` flag that indicates whether Oh My Zsh! should be installed. |
| Non-free packages flag | `nonFreePackages` | `false` | A `true`/`false` flag that non-free channel packages like `manpages-posix` should be installed. |

> **Note:** Previous versions of this script also installed Oh My Bash! but this has been dropped in favor of a simplified, default PS1 since it conflicted with common user configuration. A stub has been added so those that may have referenced it in places like their dotfiles are informed of the change and how to add it back if needed.

## Usage

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "common": {
        "username": "automatic",
        "uid": "automatic",
        "gid": "automatic",
        "installZsh": true,
        "installOhMyZsh": true,
        "upgradePackages": true,
        "nonFreePackages": false
    }
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

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

That's it!

## Speeding up the command prompt in large repositories

This script provides a custom command prompt that includes information about the git repository for the current folder. However, with certain large repositories, this can result in a slow command prompt since the required git status command can be slow. To resolve this, you can update a git setting to remove the git portion of the command prompt.

To disable the prompt for the current folder's repository, enter the following in a terminal or add it to your `postCreateCommand` or dotfiles:

```bash
git config codespaces-theme.hide-status 1
```

This setting will survive a rebuild since it is applied to the repository rather than the container.

> **Note:** If this setting is not working and you have a copy of `common-debian.sh` in your `.devcontainer/library-scripts` folder, update it to the latest version of this script.
