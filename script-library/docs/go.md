# Go (golang) Install Script

*Installs Go and common Go utilities. Auto-detects latest version and installs needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

## Syntax

```text
./go-debian.sh [Go version] [GOROOT] [GOPATH] [Non-root user] [Add to rc files flag] [Install tools flag]
```

|Argument|Default|Description|
|--------|-------|-----------|
|Go version|`latest`| Version of Go to install. Use `latest` to install the latest released version. |
|GOROOT|`/usr/local/go`| Location to install Go. |
|GOPATH|`/go`| Location to use as the `GOPATH`. Tools are installed under `${GOPATH}/bin` |
|Non-root user|`automatic`| Specifies a user in the container other than root. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | `true` | A `true`/`false` flag that indicates whether the `PATH` should be updated and `GOPATH` and `GOROOT` set via `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |
| Install tools flag | `true` | A `true`/`false` flag that indicates whether to install common Go utilities. |

## Usage

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
