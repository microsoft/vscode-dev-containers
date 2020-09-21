# PowerShell Install Script

*Installs PowerShell along with needed dependencies. Useful for base Dockerfiles that often are missing required install dependencies like gpg.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

## Syntax

```text
./powsershell-debian.sh
```

## Usage

Usage:

1. Add [`powershell-debian.sh`](../powershell-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/powershell-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/powershell-debian.sh
    ```

That's it!
