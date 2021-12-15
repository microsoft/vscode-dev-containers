# Dotnet CLI Install Script

*Installs the Dotnet CLI. Provides option of installing sdk or runtime, and option of versions to install. Uses latest version of Dotnet sdk as defaults to install.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./dotnet-debian.sh [dotnet version] [dotnet runtime only] [non-root user] [add TARGET_INSTALL_PATH to rc files flag] [install path] [access group name]
```

Or as a feature:

```json
"features": {
    "dotnet": {
      "version": "latest",
      "runtimeOnly": false
    }
}
```

|Argument|Feature option|Default|Description|
|--------|--------------|-------|-----------|
|DOTNET_VERSION| `version` | `latest`| Version of Dotnet to install. Use `latest` to install the latest released version. |
|DOTNET_RUNTIME_ONLY| `runtimeOnly` | `false` | Install just the dotnet runtime if true, and sdk if false. |
|Non-root user| | `automatic`| Specifies a user in the container other than root. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | | `true` | A `true`/`false` flag that indicates whether the `PATH` should be updated and `TARGET_INSTALL_PATH` set via `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |
|Target installation path| | `/usr/local/dotnet`| Location to install Dotnet. |
|Dotnet access group| |`dotnet`| Specifies the name of the group that will own the Dotnet installation. The installing user will be added to that group automatically.|

## Usage

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "dotnet": {
      "version": "latest",
      "runtimeOnly": false
    }
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

1. Add [`dotnet-debian.sh`](../dotnet-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/dotnet-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/dotnet-debian.sh
    ```

That's it!
