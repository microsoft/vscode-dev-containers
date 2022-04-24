# Homebrew Install Script

> **Note:** This is a community contributed and maintained script.

*Adds Homebrew to a container.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** [@andreiborisov](https://github.com/andreiborisov)

## Syntax

```text
./homebrew-debian.sh [Non-root user] [Add to rc files flag] [Use shallow clone flag] [BREW_PREFIX]
```

Or as a feature:

```json
"features": {
    "homebrew": {
        "version": "latest",
        "shallow": false
    }
}
```

|Argument| Feature option |Default|Description|
|--------|----------------|-------|-----------|
|Non-root user| | `automatic`| Specifies a user in the container other than root that will use Homebrew. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | | `true` | A `true`/`false` flag that indicates whether the `PATH` should be updated via `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |
| Use shallow clone flag | `shallow` | `false` | A `true`/`false` flag that indicates whether the script should install Homebrew using shallow clone. Shallow clone allows significantly reduce installation size at the expense of not being able to run `brew update` meaning the package index will be frozen at the moment of image creation. |
| BREW_PREFIX | | `/home/linuxbrew/.linuxbrew` | Location to install Homebrew. Please note that changing this setting will prevent you from using some of the precompiled binaries and therefore isn't recommended. |

## Usage

### Feature use

You can use this script for your primary dev container by adding it to the `features` property in `devcontainer.json`.

```json
"features": {
    "homebrew": {
        "version": "latest",
        "shallow": false
    }
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

Usage:

1. Add [`homebrew-debian.sh`](../homebrew-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    ENV BREW_PREFIX=/home/linuxbrew/.linuxbrew
    ENV PATH=${BREW_PREFIX}/sbin:${BREW_PREFIX}/bin:${PATH}
    COPY library-scripts/homebrew-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/homebrew-debian.sh
    ```

That's it!
