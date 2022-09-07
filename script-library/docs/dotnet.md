**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `dotnet` Feature to [devcontainers/features/src/dotnet](https://github.com/devcontainers/features/tree/main/src/dotnet).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Dotnet CLI Install Script

*Installs the .NET CLI. Provides option of installing sdk or runtime, and option of versions to install. Uses latest version of .NET sdk as defaults to install.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./dotnet-debian.sh [.NET version] [.NET runtime only] [non-root user] [add TARGET_DOTNET_ROOT to rc files flag] [.NET root] [access group name]
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
|DOTNET_VERSION| `version` | `latest`| Version of .NET to install. Use `latest` to install the latest released version. |
|DOTNET_RUNTIME_ONLY| `runtimeOnly` | `false` | Install just the .NET runtime if true, and sdk if false. |
|Non-root user| | `automatic`| Specifies a user in the container other than root. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | | `true` | A `true`/`false` flag that indicates whether the `PATH` should be updated and `TARGET_INSTALL_PATH` set via `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |
|Target installation root| | `/usr/local/dotnet`| Location to install .NET. |
|.NET access group| |`dotnet`| Specifies the name of the group that will own the .NET installation. The installing user will be added to that group automatically.|

## Supported Versions

The `dotnet-debian.sh` script supports the following `DOTNET_VERSION` input formats:

- **latest**: if given the keyword "latest", it will attempt to retrieve the latest .NET version.
- **MAJOR**: if given a MAJOR version, it will attempt to retrieve the latest matching MAJOR.minor.patch version.
- **MAJOR.minor**: if given a MAJOR.minor version, it will attempt to retrieve the latest matching MAJOR.minor.patch version.
- **MAJOR.minor.patch**: if given a MAJOR.minor.patch version, it will attempt to retrieve the exact match.

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
    ENV DOTNET_ROOT="/usr/local/dotnet"
    ENV PATH="${PATH}:${DOTNET_ROOT}"
    COPY library-scripts/dotnet-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/dotnet-debian.sh
    ```

That's it!
