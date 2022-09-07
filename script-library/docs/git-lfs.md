**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `git-lfs` Feature to [devcontainers/features/src/git-lfs](https://github.com/devcontainers/features/tree/main/src/git-lfs).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Git LFS Install Script

*Installs Git Large File Support (Git LFS) along with needed dependencies. Useful for base Dockerfiles that often are missing required install dependencies like git and curl.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./git-lfs-debian.sh [Version]
```

Or as a feature:

```json
"features": {
    "git-lfs": "latest"
}
```

|Argument|Feature option|Default|Description|
|--------|--------------|-------|-----------|
|Version| `version` | `latest`| Version of Git to build and install. Use `latest` to install the latest stable version. |

## Usage

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "git-lfs": "latest"
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

1. Add [`git-lfs-debian.sh`](../git-lfs-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/git-lfs-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/git-lfs-debian.sh
    ```

That's it!
