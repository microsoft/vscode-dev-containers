**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `git` Feature to [devcontainers/features/src/git](https://github.com/devcontainers/features/tree/main/src/git).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Git Build/Install from Source Script

*Install an up-to-date version of Git and build from source as needed. Useful for when you want the latest and greatest features. Auto-detects latest stable version and installs needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./git-from-src-debian.sh [Version] [Use PPA if available]
```

Or as a feature:

```json
"features": {
    "git": {
        "version": "latest",
        "ppa": false
    }
}
```

|Argument|Feature option|Default|Description|
|--------|--------------|-------|-----------|
|Version| `version` | `latest`| Version of Git to build and install. Use `latest` to install the latest stable version. Use `os-provided` to skip building and install the pre-compiled version of Git comes with the Linux distribution instead (much faster). |
|Use PPA if available| `ppa` | `false`| If using Ubuntu and a build already exists in the git-core PPA, use it instead of building from scratch. |

## Usage

### Feature use

You can use this script for your primary dev container by adding it to the `features` property in `devcontainer.json`.

```json
"features": {
    "git": {
        "version": "latest",
        "ppa": false
    }
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

1. Add [`git-from-src-debian.sh`](../git-from-src-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/git-from-src-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/git-from-src-debian.sh
    ```

That's it!
