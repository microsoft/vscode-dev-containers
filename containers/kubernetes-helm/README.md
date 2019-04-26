# Kubernetes and Helm

## Summary

*Access a local (or remote) Kubernetes cluster from inside a dev container. Includes kubectl, Helm, and the Docker CLI.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code team |
| *Definition type* | Dockerfile |
| *Languages, platforms* | Any |

## Description

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into a local or remote [Kubernetes](https://kubernetes.io/) cluster without affecting your dev container.

This example illustrates how you can do this by using CLIs ([kubectl](https://kubernetes.io/docs/reference/kubectl/overview/), [Helm](https://helm.sh), Docker), the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools), and the [Docker extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) right from inside your dev container.  This definition builds up from the [docker-in-docker](../docker-in-docker) container definition to add Kubernetes and Helm support.  It installs the Docker and Kubernetes extensions inside the container so you can use its full feature set with your project.

The dev container also syncs your local Kubernetes config (`~/.kube/config` or `%USERPROFILE%\.kube\config`) into the container with the necessary modifications to allow it to interact with anything running on your local machine whenever the container or a terminal window is started. This includes interacting with a Kubernetes cluster managed through Docker Desktop or a local Minikube install.

## How it works / adapting your existing dev container config

You can adapt your own existing development container Dockerfile to support this scenario by following these steps:

1. First, install all of the needed CLIs in the container. From `.devcontainer/Dockerfile`:

    ```Dockerfile
    # Install Docker CE CLI
    RUN apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common lsb-release \
        && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
        && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
        && apt-get update \
        && apt-get install -y docker-ce-cli

    # Install kubectl
    RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - 2>/dev/null \
        && echo "deb https://apt.kubernetes.io/ kubernetes-$(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
        && apt-get update \
        && apt-get install -y kubectl

    # Install Helm
    RUN curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash -
    ```

2. Next, forward the local Docker socket and mount the local `.kube` folder in the container so the configuration can be reused. From `.devcontainer/devcontainer.json`:

    ```json
        "runArgs": ["-e", "SYNC_LOCALHOST_KUBECONFIG=true",
            "-v", "/var/run/docker.sock:/var/run/docker.sock",
            "-v", "$HOME/.kube:/root/.kube-localhost"]
    ```

3. Update `.bashrc` to automatically swap out localhost for host.docker.internal in a containr copy of the Kubernetes config. From `.devcontainer/Dockerfile`:

    ```Dockerfile
    RUN echo 'if [ "$SYNC_LOCALHOST_KUBECONFIG" == "true" ]; then \
            mkdir -p $HOME/.kube \
            && cp -r $HOME/.kube-localhost/* $HOME/.kube \
            && sed -i -e "s/localhost/host.docker.internal/g" $HOME/.kube/config; \
            fi' >> $HOME/.bashrc
    ```

5. Add a container specific user settings file that forces the Docker extension to be installed inside the container instead of locally. From `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY settings.vscode.json /root/.vscode-remote/data/Machine/settings.json
    ```

    From `.devcontainer/settings.vscode.json`:

    ```json
    {
        "remote.extensionKind": {
            "peterjausovec.vscode-docker": "workspace"
        }
    }
    ```

6. Press <kbd>F1</kbd> and run **Remote-Containers: Rebuild Container** so the changes take effect.

That's it!

## Using this definition with an existing folder

There are no special setup steps are required, but note that the included `.devcontainer/Dockerfile` can be altered to work with other Debian/Ubuntu-based container images such as `node` or `python`. Just, update the `FROM` statement to reference the new base image. For example:

```Dockerfile
FROM node:lts
```

In addition, if you want to **disable sync'ing** local Kubernetes config into the container, remove `"-e", "SYNC_LOCALHOST_KUBECONFIG=true",` from `runArgs` in `.devcontainer/devcontainer.json`.

Follow the steps below for your operating system to use the definition.

### macOS  / Windows

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. Start Docker, right-click on the Docker icon and select "Preferences..."

3. Check **Kubernetes > Enable Kubernetes**

4. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Create Container Configuration File...** from the command palette.
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

## Linux Setup

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
   
2. Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) on your local OS if you have not already.

3. Start Minikube as follows:
    ```
    minikube start
    kubectl config set-context minikube
    ```

4. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Create Container Configuration File...** from the command palette.
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

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE). 
