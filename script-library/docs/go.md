**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `go` Feature to [devcontainers/features/src/go](https://github.com/devcontainers/features/tree/main/src/go).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Go (golang) Install Script

*Installs Go and common Go utilities. Auto-detects latest version and installs needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./go-debian.sh [Go version] [GOROOT] [GOPATH] [Non-root user] [Add to rc files flag] [Install tools flag]
```

Or as a feature:

```json
"features": {
    "golang": "latest"
}
```

|Argument|Feature option|Default|Description|
|--------|--------------|-------|-----------|
|Go version|`version` | `latest`| Version of Go to install. Use `latest` to install the latest released version. Partial version numbers are accepted (e.g. `1.19`).|
|GOROOT| | `/usr/local/go`| Location to install Go. |
|GOPATH| | `/go`| Location to use as the `GOPATH`. Tools are installed under `${GOPATH}/bin` |
|Non-root user| | `automatic`| Specifies a user in the container other than root. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | | `true` | A `true`/`false` flag that indicates whether the `PATH` should be updated and `GOPATH` and `GOROOT` set via `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |
| Install tools flag | | `true` | A `true`/`false` flag that indicates whether to install common Go utilities. |

## Usage

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "golang": "latest"
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

1. Add [`go-debian.sh`](../go-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    ENV GOROOT=/usr/local/go \
        GOPATH=/go
    ENV PATH=${GOPATH}/bin:${GOROOT}/bin:${PATH}
    COPY library-scripts/go-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/go-debian.sh "latest" "${GOROOT}" "${GOPATH}"
    ```

That's it!
