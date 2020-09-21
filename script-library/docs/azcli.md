# Azure CLI Install Script

*Installs the Azure CLI along with needed dependencies. Useful for base Dockerfiles that often are missing required install dependencies like gpg.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

## Syntax

```text
./azcli-debian.sh
```

## Usage

1. Add [`azcli-debian.sh`](../azcli-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/azcli-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/azcli-debian.sh
    ```

That's it!
