# Git Build/Install from Source Script

*Install an up-to-date version of Git and build from source as needed. Useful for when you want the latest and greatest features. Auto-detects latest stable version and installs needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./git-from-src-debian.sh [Version] [Use PPA if available]
```

|Argument|Default|Description|
|--------|-------|-----------|
|Version|`latest`| Version of Git to build and install. Use `latest` to install the latest stable version. |
|Use PPA if available|`false`| If using Ubuntu and a build already exists in the git-core PPA, use it instead of building from scratch. |

## Usage

1. Add [`git-from-src-debian.sh`](../git-from-src-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/git-from-src-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/git-from-src-debian.sh
    ```

That's it!
