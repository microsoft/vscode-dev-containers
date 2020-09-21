# Kubectl and Helm Install Script

*Installs latest version of kubectl and Helm. Auto-detects latest version and installs needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

## Syntax

```text
./kubectl-helm-debian.sh
```

## Usage

Usage:

1. Add [`kubectl-helm-debian.sh`](../kubectl-helm-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/kubectl-helm-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/kubectl-helm-debian.sh
    ```

That's it!
