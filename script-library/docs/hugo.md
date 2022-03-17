# Hugo Install Script

*Installs hugo, and needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./hugo-debian.sh [Hugo version] [HUGO_DIR] [Non-root user] [Add rc files flag]
```

Or as a feature:

```json
"features": {
    "hugo": "latest"
}
```

|Argument| Feature option |Default|Description|
|--------|----------------|-------|-----------|
|Hugo version| `version` | `latest`| Version of Hugo to install. Specify `latest` to install the latest version. |
|HUGO_DIR| | `/usr/local/hugo`| Location to install Hugo |
|Non-root user| | `automatic`| Specifies a user in the container other than root that will use Gradle. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | | `true` | A `true`/`false` flag that indicates whether sourcing the nvm script should be added to `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |

## Usage

### Feature use

You can use this script for your primary dev container by adding it to the `features` property in `devcontainer.json`.

```json
"features": {
    "hugo": "latest"
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

1. Add [`hugo-debian.sh`](../hugo-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    ENV HUGO_DIR="/usr/local/hugo"
    ENV PATH=${HUGO_DIR}/bin:${PATH}
    COPY library-scripts/hugo-debian.sh /tmp/library-scripts/
    RUN bash /tmp/library-scripts/hugo-debian.sh "latest" "${HUGO_DIR}"
    ```

That's it!
