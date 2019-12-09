# Kubernetes and Helm

## Summary

*Access a local (or remote) Kubernetes cluster from inside a dev container. Includes kubectl, Helm, and the Docker CLI.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code team and Phetsinorath William |
| *Definition type* | Dockerfile |
| *Languages, platforms* | Any |

## Description

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into a local or remote [Kubernetes](https://kubernetes.io/) cluster without affecting your dev container.

This example illustrates how you can do this by using CLIs ([kubectl](https://kubernetes.io/docs/reference/kubectl/overview/), [Helm](https://helm.sh), Docker), the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools), and the [Docker extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) right from inside your dev container.  This definition builds up from the [docker-in-docker](../docker-in-docker) container definition to add Kubernetes and Helm support.  It installs the Docker and Kubernetes extensions inside the container so you can use its full feature set with your project.

The dev container also syncs your local Kubernetes config (`~/.kube/config` or `%USERPROFILE%\.kube\config`) into the container with the necessary modifications to allow it to interact with anything running on your local machine whenever the container or a terminal window is started. This includes interacting with a Kubernetes cluster managed through Docker Desktop or a local Minikube install.

## How it works / adapting your existing dev container config

You can adapt your own existing development container Dockerfile to support this scenario by following these steps:

1. First, update your `devcontainer.json` to forward the local Docker socket and mount the local `.kube` folder in the container so its contents can be reused. From `.devcontainer/devcontainer.json`:

    ```json
    "mounts": [
        "source=/var/run/docker.sock,target=/var/run/docker.sock",
        "source=${env:HOME}${env:USERPROFILE}/.kube,target=/root/.kube-localhost,type=bind"
    ],
    "remoteEnv": {
        "SYNC_LOCALHOST_KUBECONFIG": "true"
    }
    ```

    If you also want to reuse your Minikube certificates, just add a mount for your local `.minikube` folder as well:

    ```json
    "mounts": [
        "source=/var/run/docker.sock,target=/var/run/docker.sock",
        "source=${env:HOME}${env:USERPROFILE}/.kube,target=/root/.kube-localhost,type=bind",
        "source=${env:HOME}${env:USERPROFILE}/.minikube,target=/root/.minikube-localhost,type=bind"
    ],
    "remoteEnv": {
        "SYNC_LOCALHOST_KUBECONFIG": "true"
    }
    ```

2. Next, update your Dockerfile so the default shell is `bash`, and then add a script to automatically swap out `localhost` for `host.docker.internal` in the container's copy of the Kubernetes config and (optionally) Minikube certificates to `.bashrc`. From `.devcontainer/Dockerfile`:

    ```Dockerfile
    RUN echo '\n\
    if [ "$SYNC_LOCALHOST_KUBECONFIG" == "true" ]; then\n\
        mkdir -p $HOME/.kube\n\
        cp -r $HOME/.kube-localhost/* $HOME/.kube\n\
        sed -i -e "s/localhost/host.docker.internal/g" $HOME/.kube/config\n\
    \n\
        if [ -d "$HOME/.minikube-localhost" ]; then\n\
            mkdir -p $HOME/.minikube\n\
            cp -r $HOME/.minikube-localhost/ca.crt $HOME/.minikube\n\
            sed -i -r "s|(\s*certificate-authority:\s).*|\\1$HOME\/.minikube\/ca.crt|g" $HOME/.kube/config\n\
            cp -r $HOME/.minikube-localhost/client.crt $HOME/.minikube\n\
            sed -i -r "s|(\s*client-certificate:\s).*|\\1$HOME\/.minikube\/client.crt|g" $HOME/.kube/config\n\
            cp -r $HOME/.minikube-localhost/client.key $HOME/.minikube\n\
            sed -i -r "s|(\s*client-key:\s).*|\\1$HOME\/.minikube\/client.key|g" $HOME/.kube/config\n\
        fi\n\
    fi' \
    >> $HOME/.bashrc
    ```

3. Finally, update your Dockerfile to install all of the needed CLIs in the container. From `.devcontainer/Dockerfile`:

    ```Dockerfile
    RUN apt-get update \
        #
        # Install Docker CE CLI
        && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common lsb-release \
        && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
        && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
        && apt-get update \
        && apt-get install -y docker-ce-cli \
        #
        # Install kubectl
        && curl -sSL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
        && chmod +x /usr/local/bin/kubectl \
        #
        # Install Helm
        curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash -
    ```

4. Press <kbd>F1</kbd> and run **Remote-Containers: Rebuild Container** so the changes take effect.

That's it!

## Using this definition with an existing folder

A few notes on the definition:

* The included `.devcontainer/Dockerfile` can be altered to work with other Debian/Ubuntu-based container images such as `node` or `python`. Just, update the `FROM` statement to reference the new base image. For example:

    ```Dockerfile
    FROM node:lts
    ```

* If you also want to sync your Minikube certificates, open `.devcontainer/devcontainer.json` and uncomment this line in the `mount` property :

    ```json
    "source=${env:HOME}${env:USERPROFILE}/.minikube,target=/root/.minikube-localhost,type=bind",
    ```

* If you want to **disable sync'ing** local Kubernetes config / Minikube certs into the container, remove `"SYNC_LOCALHOST_KUBECONFIG": "true",` from `remoteEnv` in `.devcontainer/devcontainer.json`.

See the section below for your operating system for more detailed setup instructions.

### Windows / macOS

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. Start Docker, right-click on the Docker icon and select "Preferences..."

3. Check **Kubernetes > Enable Kubernetes**

4. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Docker in Docker Compose definition.

5. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/docker-in-docker-compose/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

6. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

7. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

8. [Optional] If you want to use [Helm](https://helm.sh), open a VS Code terminal and run:

    ```
    helm init
    ```

## Linux / Minikube Setup

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) on your local OS if you have not already.

3. Start Minikube as follows:
    ```
    minikube start
    kubectl config set-context minikube
    ```

4. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Docker in Docker Compose definition.

5. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/docker-in-docker-compose/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

6. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

7. Open `.devcontainer/devcontainer.json` and uncomment this line in the `runArgs` array:

    ```json
    "--mount", "type=bind,source=${env:HOME}${env:USERPROFILE}/.minikube,target=/root/.minikube-localhost",
    ```

8. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

9. [Optional] If you want to use [Helm](https://helm.sh), open a VS Code terminal and run:
    ```
    helm init
    ```

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE). 
