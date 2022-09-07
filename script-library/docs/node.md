**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `node` Feature to [devcontainers/features/src/node](https://github.com/devcontainers/features/tree/main/src/node).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Node.js Install Script

*Installs Node.js, nvm, yarn, and needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./node-debian.sh [Location to install nvm] [node version to install (use "none" to skip)] [non-root user] [Update rc files flag] [Install node-gyp deps flag]
```

Or as a feature:

```json
"features": {
    "node": {
        "version": "lts",
        "nodeGypDependencies": true
    }
}
```

|Argument|Feature option|Default|Description|
|--------|--------------|-------|-----------|
|Location to install nvm| | `/usr/local/share/nvm`| Location to install the [Node Version Manager (nvm)](http://nvm.sh) along with Node.js and Node modules. |
|Node version to install| `version` | `lts`| Node.js version to install. Use `none` to skip installing anything and just install nvm and yarn. |
|Non-root user| | `automatic`| Specifies a user in the container other than root that will use Node.js. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | | `true` | A `true`/`false` flag that indicates whether sourcing the nvm script should be added to `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |
| Install node-gyp deps flag | `nodeGypDependencies` | `true` | A `true`/`false` flag that indicates whether the script should check for key requirements for node-gyp (python, make, gcc) and install them if missing. |

## Usage

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "node": {
        "version": "lts",
        "nodeGypDependencies": true
    }
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

1. Add [`node-debian.sh`](../node-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    ENV NVM_DIR="/usr/local/share/nvm"
    ENV NVM_SYMLINK_CURRENT=true \
        PATH=${NVM_DIR}/current/bin:${PATH}
    COPY library-scripts/node-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}"
    ```

### Using nvm from a Dockerfile or postCreateCommand

Certain operations like `postCreateCommand` run non-interactive, non-login shells. Unfortunately, `nvm` is really particular that it needs to be "sourced" before it is used - which can only be done from interactive or login shells (via an rc or profile file).

Try doing the following instead:

```json
"postCreateCommand": "bash -i -c 'nvm install --lts'"
```

Or you can source the file before using nvm:

```json
"postCreateCommand": ". ${NVM_DIR}/nvm.sh && nvm install --lts"
```

That's it!
