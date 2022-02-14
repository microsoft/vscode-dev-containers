# Azure CLI Install Script

*Installs the Azure CLI along with needed dependencies. Useful for base Dockerfiles that often are missing required install dependencies like gpg.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./azcli-debian.sh [Version]
```

Or as a feature:

```json
"features": {
    "azure-cli": "latest"
}
```

## Usage

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "azure-cli": "latest"
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

1. Add [`azcli-debian.sh`](../azcli-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/azcli-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/azcli-debian.sh
    ```

That's it!
