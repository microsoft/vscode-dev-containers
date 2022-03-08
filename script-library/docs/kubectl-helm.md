# Kubectl, Helm, and Minikube Install Script

*Installs latest version of kubectl, Helm, and optionally minikube. Auto-detects latest versions and installs needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./kubectl-helm-debian.sh [kubectl version] [Helm version] [Minikube version] [kubectl SHA256] [Helm SHA256] [minikube SHA256] [Non-root user]
```

Or as a feature:

```json
"features": {
    "kubectl-helm-minikube": {
        "version": "latest",
        "helm": "latest",
        "minikube": "latest"
    }
}
```

|Argument| Feature option |Default|Description|
|--------|----------------|-------|-----------|
|kubectl version| `version` | `latest`| Version of kubectl to install. e.g. `v1.19` Use `latest` to install the latest stable version. |
|Helm version|`helm`|`latest`| Version of Helm to install. e.g. `v3.5` Use `latest` to install the latest stable version. |
|minikube version| `minikube`| `none`| Version of Minikube to install. e.g. `v1.19` Specifying `none` skips installation while `latest` installs the latest stable version.  |
|kubectl SHA256| | `automatic`| SHA256 checksum to use to verify the kubectl download. `automatic` will download the checksum. |
|Helm SHA256| | `automatic`| SHA256 checksum to use to verify the Helm download. `automatic` will both acquire the checksum and do a signature verification of it. |
|minikube SHA256| | `automatic`| SHA256 checksum to use to verify the minikube download. `automatic` will download the checksum. |
|Non-root user| | `automatic`| Specifies a user in the container other than root that will be using the desktop. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |

## Usage

### Feature use

You can use this script for your primary dev container by adding it to the `features` property in `devcontainer.json`.

```json
"features": {
    "kubectl-helm-minikube": {
        "version": "latest",
        "helm": "latest",
        "minikube": "latest"
    }
}
```

**[Optional]** You may also want to enable the [tini init process](https://docs.docker.com/engine/reference/run/#specify-an-init-process) to handle signals and clean up [Zombie processes](https://en.wikipedia.org/wiki/Zombie_process) if you do not have an alternative set up. To enable it, add the following to `devcontainer.json` if you are referencing an image or Dockerfile:

```json
"runArgs": ["--init"]
```

Or when using Docker Compose:

```yaml
services:
  your-service-here:
    # ...
    init: true
    # ...
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

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

3. **[Optional]** You may also want to enable the [tini init process](https://docs.docker.com/engine/reference/run/#specify-an-init-process) to properly handle signals and ensure [Zombie Processes](https://en.wikipedia.org/wiki/Zombie_process) are cleaned up if you do not have an alternative set up. To do so, add the following to `.devcontainer/devcontainer.json` if you are referencing an image or Dockerfile:

    ```json
    "runArgs": ["--init"]
    ```

    Or if you are referencing a Docker Compose file, add this to your `docker-compose.yml` file instead:
    
    ```yaml
    your-service-name-here:
      # ...
      init: true
      # ...
    ```

    While technically optional, `

3. You may also want to install Docker using the [docker-in-docker](docker-in-docker.md) or [docker-from-docker](docker.md) scripts.

That's it!
