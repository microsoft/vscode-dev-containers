# Node.js Install Script

*Installs Node.js, nvm, yarn, and needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

## Syntax

```text
./node-debian.sh [Location to install nvm] [node version to install (use "none" to skip)] [non-root user] [Update rc files flag]
```

|Argument|Default|Description|
|--------|-------|-----------|
|Location to install nvm|`/usr/local/share/nvm`| Location to install the [Node Version Manager (nvm)](http://nvm.sh) along with Node.js and Node modules. |
|Node version to install|`lts/*`| Node.js version to install. Use `none` to skip installing anything and just install nvm and yarn. |
|Non-root user|`automatic`| Specifies a user in the container other than root that will be using the desktop. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | `true` | A `true`/`false` flag that indicates whether sourcing the nvm script should be added to `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |

## Usage

Usage:

1. Add [`rust-debian.sh`](../rust-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    ENV CARGO_HOME=/usr/local/cargo \
        RUSTUP_HOME=/usr/local/rustup
    ENV PATH=${CARGO_HOME}/bin:${RUSTUP_HOME}/bin:${PATH}
    COPY library-scripts/go-debian.sh /tmp/library-scripts/
    RUN bash /tmp/library-scripts/go-debian.sh "${CARGO_HOME}" "${RUSTUP_HOME}"
    ```

That's it!
