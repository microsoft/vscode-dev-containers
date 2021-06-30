# Kubernetes - Local Configuration

## Summary

*Access a local (or remote) Kubernetes cluster from inside a dev container using your local config. Includes kubectl, Helm, and the Docker CLI.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code team and Phetsinorath William |
| *Categories* | Other |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | No |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Any |

## Description

> **Note:** If you're using Codespaces or would prefer to not set up Kubernetes locally, you may find the [Kubernetes - Minikube-in-Docker](../kubernetes-helm-minikube) definition more interesting.

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into a local minikube or remote [Kubernetes](https://kubernetes.io/) cluster without affecting your dev container.

This example illustrates how you can do this by using CLIs ([kubectl](https://kubernetes.io/docs/reference/kubectl/overview/), [Helm](https://helm.sh), Docker), the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools), and the [Docker extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) right from inside your dev container.  This definition builds up from the [docker-from-docker](../docker-from-docker) container definition to add Kubernetes and Helm support. It installs the Docker and Kubernetes extensions inside the container so you can use its full feature set with your project.

When using Remote - Containers, the dev container also syncs your local Kubernetes config (`~/.kube/config` or `%USERPROFILE%\.kube\config`) into the container with the necessary modifications to allow it to interact with anything running on your local machine whenever the container or a terminal window is started. This includes interacting with a Kubernetes cluster managed through Docker Desktop or a local Minikube install. (Note that this does **not** happen when using **GitHub Codespaces**, so you may find the [Kubernetes - Minikube-in-Docker](../kubernetes-helm-minikube) definition more interesting for this scenario.)

## How it works / adapting your existing dev container config

The [`.devcontainer` folder in this repository](.devcontainer) contains a complete example that **you can simply change the `FROM` statement** to another Debian/Ubuntu based image to adapt to your own use (along with adding anything else you need).

However, this section will outline the how you can selectively add this functionality to your own Dockerfile. Follow these steps:

1. First, see the [docker-from-docker definition](../docker-from-docker) for information on how make your local Docker instance available in the dev container. However, the [`docker` script](../../script-library/docs/docker.md) in the script library provides an easy way to add this to your own Dockerfile, so we'll assume you're using the script.

2. Next, update your `devcontainer.json` to mount your local `.kube` folder in the container so its contents can be reused. From `.devcontainer/devcontainer.json`:

    ```json
    "mounts": [
        "source=/var/run/docker.sock,target=/var/run/docker-host.sock",
        "source=${env:HOME}${env:USERPROFILE}/.kube,target=/usr/local/share/kube-localhost,type=bind"
    ],
    "remoteEnv": {
        "SYNC_LOCALHOST_KUBECONFIG": "true"
    }
    ```

    If you also want to reuse your local minikube certificates, just add a mount for your local `.minikube` folder as well:

    ```json
    "mounts": [
        "source=/var/run/docker.sock,target=/var/run/docker.sock",
        "source=${env:HOME}${env:USERPROFILE}/.kube,target=/usr/local/share/kube-localhost,type=bind",
        "source=${env:HOME}${env:USERPROFILE}/.minikube,target=/usr/local/share/minikube-localhost,type=bind"
    ],
    "remoteEnv": {
        "SYNC_LOCALHOST_KUBECONFIG": "true"
    }
    ```

3. Next, you can use the [`kubectl-helm` script](../../script-library/docs/kubectl-helm.md) or just add the following lines to your Dockerfile to install kubectl and Helm:

    ```Dockerfile
    # Install kubectl
    RUN curl -sSL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
        && chmod +x /usr/local/bin/kubectl

    # Install Helm
    RUN curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -
    ```

4. Finally, we need to automatically swap out `localhost` for `host.docker.internal` in the container's copy of the Kubernetes config and (optionally) Minikube certificates. Manually copy the [`copy-kube-config.sh` script](.devcontainer/copy-kube-config.sh) from the `.devcontainer` folder in this repo folder into the same folder as your `Dockerfile` and then update your `Dockerfile` to use it from your `/root/.bashrc` and/or `/root/.zshrc`.

    ```Dockerfile
    COPY copy-kube-config.sh /usr/local/share/
    RUN echo "source /usr/local/share/copy-kube-config.sh" | tee -a /root/.bashrc >> /root/.zshrc
    ```

5. Press <kbd>F1</kbd> and run **Remote-Containers: Rebuild Container** so the changes take effect.


That's it!

## A note on Minkube or otherwise using a local cluster

While this definition works with Minkube in most cases, if you hit trouble, make sure that your `~/.kube/config` file and Minikube certs reference your host's IP rather than `127.0.0.1` or `localhost` (since `localhost` resolve to the container itself rather than your local machine where Minikube is running).

This should happen by default on Linux. On macOS and Windows, we recommend using the Kuberntes install that comes with Docker Desktop instead of Minikube to avoid these kinds of issues.

## Using this definition with an existing folder

A few notes on the definition:

* The included `.devcontainer/Dockerfile` can be altered to work with other Debian/Ubuntu-based container images such as `node` or `python`. Just, update the `FROM` statement to reference the new base image. For example:

    ```Dockerfile
    FROM node:lts
    ```

* If you also want to sync your Minikube certificates, open `.devcontainer/devcontainer.json` and uncomment this line in the `mount` property :

    ```json
    "source=${env:HOME}${env:USERPROFILE}/.minikube,target=/usr/local/share/minikube-localhost,type=bind",
    ```

* If you want to **disable sync'ing** local Kubernetes config / Minikube certs into the container, remove `"SYNC_LOCALHOST_KUBECONFIG": "true",` from `remoteEnv` in `.devcontainer/devcontainer.json`.

See the section below for your operating system for more detailed setup instructions.

### Windows / macOS

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. Start Docker, right-click on the Docker icon and select "Preferences..."

3. Check **Kubernetes > Enable Kubernetes**

4. Start VS Code and open your project folder.

5. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.

6.  Select this definition. You may also need to select **Show All Definitions...** for it to appear.

7. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

### Linux / Minikube Setup

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) on your local OS if you have not already.

3. Start Minikube as follows:
    ```
    minikube start
    kubectl config set-context minikube
    ```

4. Start VS Code and open your project folder.

5. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.

6.  Select this definition. You may also need to select **Show All Definitions...** for it to appear.

7. Open `.devcontainer/devcontainer.json` and uncomment this line in the `runArgs` array:

    ```json
    "--mount", "type=bind,source=${env:HOME}${env:USERPROFILE}/.minikube,target=/usr/local/share/minikube-localhost",
    ```

8. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.


### GitHub Codespaces

While you cannot sync or connect to your local Kubernetes configuration with Codespaces, you can use `kubectl`, Helm, and the Kubernetes extension.

1. If this is your first time using a development container, please see [creating a codespace](https://aka.ms/ghcs-open-codespace) for information on using GitHub Codespaces.

2. Create or connect to an existing codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE). 
