# Git LFS Install Script

*Installs Git Large File Support (Git LFS) along with needed dependencies. Useful for base Dockerfiles that often are missing required install dependencies like git and curl.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

## Syntax

```text
./git-lfs-debian.sh
```

## Usage

1. Add [`git-lfs-debian.sh`](../git-lfs-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/git-lfs-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/git-lfs-debian.sh
    ```

That's it!
