**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated `gradle` as [part of the `java` Feature](https://github.com/devcontainers/features/tree/main/src/java#options).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Gradle Install Script

*Installs Gradle, SDKMAN! (if not installed), and needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./gradle-debian.sh [Gradle version] [SDKMAN_DIR] [Non-root user] [Add rc files flag]
```

Or as a feature:

```json
"features": {
    "gradle": "latest"
}
```

|Argument|Feature option|Default|Description|
|--------|--------------|-------|-----------|
|Gradle version|`version`|`latest`| Version of Gradle to install. Specify `latest` to install the latest stable version. Partial version numbers are allowed. |
|SDKMAN_DIR| |`/usr/local/sdkman`| Location to find [SDKMAN!](https://sdkman.io/), or if not found, where to install it. |
|Non-root user| |`automatic`| Specifies a user in the container other than root that will use Gradle. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | | `true` | A `true`/`false` flag that indicates whether sourcing the nvm script should be added to `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |

## Usage

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "gradle": "latest"
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

1. Add [`gradle-debian.sh`](../gradle-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    ENV SDKMAN_DIR="/usr/local/sdkman"
    ENV PATH=${SDKMAN_DIR}/bin:${SDKMAN_DIR}/candidates/gradle/current/bin:${PATH}
    COPY library-scripts/gradle-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/gradle-debian.sh "latest" "${SDKMAN_DIR}"
    ```

That's it!
