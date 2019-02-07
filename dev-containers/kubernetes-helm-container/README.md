# Kubernetes and Helm Container

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into a local or remote [Kubernetes](https://kubernetes.io/) cluster without affecting your dev container. This example illustrates how you can do this by using CLIs, the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools), and the [Docker extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) right from inside your dev container.

The dev container includes the needed CLIs ([kubectl](https://kubernetes.io/docs/reference/kubectl/overview/), [Helm](https://helm.sh), Docker, and syncs your local Kubernetes config (`~/.kube/config` or `%USERPROFILE%\.kube\config`) into the container with the necessary modifications to allow it to interact with anything running on your local machine. This includes interacting with a Kubernetes cluster managed through Docker Desktop or a local Minikube install.

To get started, follow the appropriate steps below for your operating system.

## macOS Setup

1. Install "Docker Desktop for Mac" locally if you have not.

2. Start Docker, right-click on the Docker icon and select "Preferences..."

3. Check **Kubernetes > Enable Kubernetes**

4. Open this folder in VS Code

5. Edit `.vscode/devConatiner.json` and change `$HOME` in the last item in the `runArgs` array to the absolute path of your home folder. e.g.
    ```
    "runArgs": ["-e", "SYNC_LOCALHOST_KUBECONFIG=true",
        "-v", "/var/run/docker.sock:/var/run/docker.sock", 
        "-v", "/Users/clantz/.kube:/root/.kube-localhost"]
    ```
    > **Note:** Resolving [vscode-remote#670](https://github.com/Microsoft/vscode-remote/issues/670) will remove this step.

6. Run the **Remote: Reopen folder in Container** command. Once connected, you should see your clusters in the Kubernetes explorer.

7. [Optional] If you want to use [Helm](https://helm.sh), open a VS Code terminal and run:
    ```
    helm init
    ```

## Windows Setup

1. Install "Docker Desktop for Windows" locally if you have not.
   
2. Right Click on Docker system tray icon and select "Settings"
   
3. Check **General > "Expose daemon on tcp://localhost:2375 without TLS"**

4. Check **Kubernetes > Enable Kubernetes**
   
5. Open this folder in VS Code

6. Edit `.vscode/devConatiner.json` replace the **entire** contents `runArgs` of with the following. Replace `C:\\Users\\clantz\\` with the path your your user directory.
    ```
    "runArgs": ["-e", "SYNC_LOCALHOST_KUBECONFIG=true",
        "-e", "DOCKER_HOST=tcp://host.docker.internal:2375",         
        "-v", "C:\\Users\\clantz\\.kube:/root/.kube-localhost"]
    ```
    > **Note:** Resolving [vscode-remote#670](https://github.com/Microsoft/vscode-remote/issues/670) and [vscode-remote#669](https://github.com/Microsoft/vscode-remote/issues/669) will remove this step.

7. Run the **Remote: Reopen folder in Container** command. Once connected, you should see your clusters in the Kubernetes explorer.

8. [Optional] If you want to use [Helm](https://helm.sh), open a VS Code terminal and run:
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
    ```
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
