# Rust (rustlang) Install Script

*Installs Rust, common Rust utilities, and needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./rust-debian.sh [CARGO_HOME] [RUSTUP_HOME] [Non-root user] [Add to rc files flag] [Update Rust flag]
```

|Argument|Default|Description|
|--------|-------|-----------|
|CARGO_HOME|`/usr/local/cargo`| Location to install Cargo. |
|RUSTUP_HOME|`/usr/local/rustup`| Location to install rustup. |
|Non-root user|`automatic`| Specifies a user in the container other than root that will use Rust. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | `true` | A `true`/`false` flag that indicates whether the `PATH` should be updated and `CARGO_HOME` and `RUSTUP_HOME` set via `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |
| Update Rust flag | `true` | A `true`/`false` flag that indicates whether the script should update Rust (e.g. if it was already installed). |

## Usage

Usage:

1. Add [`rust-debian.sh`](../rust-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    ENV CARGO_HOME=/usr/local/cargo \
        RUSTUP_HOME=/usr/local/rustup
    ENV PATH=${CARGO_HOME}/bin:${RUSTUP_HOME}/bin:${PATH}
    COPY library-scripts/rust-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/rust-debian.sh "${CARGO_HOME}" "${RUSTUP_HOME}"
    ```

That's it!
