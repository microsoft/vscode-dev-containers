# Git Build/Install from Source Script

*Builds and installs Git from source. Useful for when you want the latest and greatest features. Auto-detects latest stable version and installs needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./git-from-src-debian.sh [Version]
```

|Argument|Default|Description|
|--------|-------|-----------|
|Version|`latest`| Version of Git to build and install. Use `latest` to install the latest stable version. |

## Usage

1. Add [`git-from-src-debian.sh`](../git-from-src-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/git-from-src-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/git-from-src-debian.sh
    ```

That's it!
