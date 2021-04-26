# GitHub CLI Install Script

*Installs the GitHub CLI. Auto-detects latest version and installs needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./github-debian.sh [Version]
```

|Argument|Default|Description|
|--------|-------|-----------|
|Version|`latest`| Version of GitHub CLI to install. Use `latest` to install the latest released version. |

## Usage

1. Add [`github-debian.sh`](../github-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/github-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/github-debian.sh
    ```

That's it!
