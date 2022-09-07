**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `rust` Feature to [devcontainers/features/src/rust](https://github.com/devcontainers/features/tree/main/src/rust).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Rust (rustlang) Install Script

*Installs Rust, common Rust utilities, and needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./rust-debian.sh [CARGO_HOME] [RUSTUP_HOME] [Non-root user] [Add to rc files flag] [Update Rust flag] [Rust version] [rustup install profile] [Rust version] [rustup profile]
```

Or as a feature:

```json
"features": {
    "rust": {
        "version": "latest",
        "profile": "minimal"
    }
}
```

|Argument|Feature option|Default|Description|
|--------|--------------|-------|-----------|
|CARGO_HOME| |`/usr/local/cargo`| Location to install Cargo. |
|RUSTUP_HOME| |`/usr/local/rustup`| Location to install rustup. |
|Non-root user| |`automatic`| Specifies a user in the container other than root that will use Rust. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | |`true` | A `true`/`false` flag that indicates whether the `PATH` should be updated and `CARGO_HOME` and `RUSTUP_HOME` set via `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |
| Update Rust flag | |`flase` | A `true`/`false` flag that indicates whether the script should update Rust (e.g. if it was already installed). |
| Rust version | `version` | `latest` | Version of Rust to install. Partial version numbers are allowed (e.g. `1.55`). |
| Rust install profile | `profile` | `minimal` | The rustup [install profile](https://rust-lang.github.io/rustup/concepts/profiles.html) to use when installing Rust. |

## Usage

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "rust": {
        "version": "latest",
        "profile": "minimal"
    }
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

Usage:

1. Add [`rust-debian.sh`](../rust-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    ENV CARGO_HOME=/usr/local/cargo \
        RUSTUP_HOME=/usr/local/rustup
    ENV PATH=${CARGO_HOME}/bin:${PATH}
    COPY library-scripts/rust-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/rust-debian.sh "${CARGO_HOME}" "${RUSTUP_HOME}"
    ```

That's it!
