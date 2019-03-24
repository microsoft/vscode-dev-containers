# Kubernetes and Helm

## Summary

*Illustrates how you access a Kubernetes cluster from inside a dev container. Includes the Docker CLI, kubectl, and Helm.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code team |
| *Definition type* | Dockerfile |
| *Languages, platforms* | Any |

## Description

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into a local or remote [Kubernetes](https://kubernetes.io/) cluster without affecting your dev container. This example illustrates how you can do this by using CLIs, the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools), and the [Docker extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) right from inside your dev container.

This example builds up from the [docker-in-docker](../docker-in-docker) container definition to add Kubernetes and Helm support.

The dev container includes the needed CLIs ([kubectl](https://kubernetes.io/docs/reference/kubectl/overview/), [Helm](https://helm.sh), Docker) and syncs your local Kubernetes config (`~/.kube/config` or `%USERPROFILE%\.kube\config`) into the container with the necessary modifications to allow it to interact with anything running on your local machine. This includes interacting with a Kubernetes cluster managed through Docker Desktop or a local Minikube install.

To get started, follow the appropriate steps below for your operating system.

## Usage

### macOS  / Windows Setup

1. Install "Docker Desktop for Mac" / "Docker Desktop for Windows" locally if you have not.

2. Start Docker, right-click on the Docker icon and select "Preferences..."

3. Check **Kubernetes > Enable Kubernetes**

4. Open this folder in VS Code

5. Edit `.vscode/devConatiner.json` and change `$HOME` in the last item in the `runArgs` array to the absolute path of your home / user profile folder. e.g. On macOS:
    
    ```json
    "runArgs": ["-e", "SYNC_LOCALHOST_KUBECONFIG=true",
        "-v", "/var/run/docker.sock:/var/run/docker.sock", 
        "-v", "/Users/clantz/.kube:/root/.kube-localhost"]
    ```
    On Windows:

    ```json
    "runArgs": ["-e", "SYNC_LOCALHOST_KUBECONFIG=true",
        "-v", "/var/run/docker.sock:/var/run/docker.sock", 
        "-v", "C:\\Users\\clantz\\.kube:/root/.kube-localhost"]
    ```

    > **Note:** Resolving [vscode-remote#670](https://github.com/Microsoft/vscode-remote/issues/670) and [vscode-remote#669](https://github.com/Microsoft/vscode-remote/issues/669) will remove this step.

6. Run the **Remote: Reopen folder in Container** command. Once connected, you should see your clusters in the Kubernetes explorer.

7. [Optional] If you want to use [Helm](https://helm.sh), open a VS Code terminal and run:
    ```
    helm init
    ```

## Linux Setup

1. Install [Docker CE](https://docs.docker.com/install/linux/docker-ce/ubuntu/), [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), and [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) on your local OS if you have not already.

2. Start Minikube as follows:
    ```
    minikube start
    kubectl config set-context minikube
    ```

3. Open this folder in VS Code

4. Edit `.vscode/devConatiner.json` and change `$HOME` in the last item in the `runArgs` array to the absolute path of your home folder. e.g.
    ```json
    "runArgs": ["-e", "SYNC_LOCALHOST_KUBECONFIG=true",
        "-v","/var/run/docker.sock:/var/run/docker.sock", 
        "-v", "/home/clantz/.kube:/root/.kube-localhost"]
    ```
    > **Note:** Resolving [vscode-remote#670](https://github.com/Microsoft/vscode-remote/issues/670) will remove this step.

5. Run the **Remote: Reopen folder in Container** command. Once connected, you should see your clusters in the Kubernetes explorer.

6. [Optional] If you want to use [Helm](https://helm.sh), open a VS Code terminal and run:
    ```
    helm init
    ```

## How it works

The trick that makes this work is as follows:

1. Install all of the needed CLIs in the container. From `dev-container.dockerfile`:

    ```Dockerfile
    # Install Docker CE CLI
    RUN apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
        && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
        && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        && apt-get update \
        && apt-get install -y docker-ce-cli

    # Install kubectl
    RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
        && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
        && apt-get update \
        && apt-get install -y kubectl

    # Install Helm
    RUN curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash -
    ```

2. Forward the local Docker socket and mount the local `.kube` folder in the container so the configuration can be reused. From `devContainer.json`:

    ```json
        "runArgs": ["-e", "SYNC_LOCALHOST_KUBECONFIG=true",
            "-v", "/var/run/docker.sock:/var/run/docker.sock",
            "-v", "$HOME/.kube:/root/.kube-localhost"]
    ```

3. Update `.bashrc` to automatically copy the local machine's Kubernetes config into the container and swap out localhost for host.docker.internal whenever a new shell starts. From `dev-container.dockerfile`:

    ```Dockerfile
    RUN echo 'if [ "$SYNC_LOCALHOST_KUBECONFIG" == "true" ]; then \
            mkdir -p $HOME/.kube \
            && cp -r $HOME/.kube-localhost/* $HOME/.kube \
            && sed -i -e "s/localhost/host.docker.internal/g" $HOME/.kube/config; \
            fi' >> $HOME/.bashrc
    ```

That's it!
