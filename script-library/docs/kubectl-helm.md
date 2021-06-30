# Kubectl and Helm Install Script

*Installs latest version of kubectl, Helm, and optionally minikube. Auto-detects latest versions and installs needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./kubectl-helm-debian.sh [kubectl version] [Helm version] [Minikube version] [kubectl SHA256] [Helm SHA256] [minikube SHA256]
```

|Argument|Default|Description|
|--------|-------|-----------|
|kubectl version|`latest`| Version of kubectl to install. e.g. `v1.19.0` Use `latest` to install the latest stable version. |
|Helm version|`latest`| Version of Helm to install. e.g. `v3.5.4` Use `latest` to install the latest stable version. |
|minikube version|`none`| Version of Minkube to install. e.g. `v3.5.4` Specifying `none` skips installation while `latest` installs the latest stable version.  |
|kubectl SHA256|`automatic`| SHA256 checksum to use to verify the kubectl download. `automatic` will download the checksum. |
|Helm SHA256|`automatic`| SHA256 checksum to use to verify the Helm download. `automatic` will both acquire the checksum and do a signature verification of it. |
|minikube SHA256|`automatic`| SHA256 checksum to use to verify the minikube download. `automatic` will download the checksum. |

## Usage

Usage:

1. Add [`kubectl-helm-debian.sh`](../kubectl-helm-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/kubectl-helm-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/kubectl-helm-debian.sh
    ```

    ...or if you want to install minikube as well...

    ```Dockerfile
    COPY library-scripts/kubectl-helm-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/kubectl-helm-debian.sh latest latest latest
    ```

3. You may also want to install Docker using the [docker-in-docker](docker-in-docker.md) or [docker-from-docker](docker.md) scripts.

That's it!
