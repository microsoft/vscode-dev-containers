**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `powershell` Feature to [devcontainers/features/src/powershell](https://github.com/devcontainers/features/tree/main/src/powershell).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# PowerShell Install Script

*Installs PowerShell along with needed dependencies. Useful for base Dockerfiles that often are missing required install dependencies like gpg.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./powsershell-debian.sh [Version]
```
Or as a feature:

```json
"features": {
    "powershell": "latest"
}
```

|Argument|Feature option|Default|Description|
|--------|--------------|-------|-----------|
|Version|`version`| `latest` | Version of PowerShell to install. Use `latest` to install the latest released version. Partial version numbers are allowed. |

## Usage

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "powershell": "latest"
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

Usage:

1. Add [`powershell-debian.sh`](../powershell-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/powershell-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/powershell-debian.sh
    ```

That's it!
