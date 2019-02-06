# Kubernetes and Helm Container

This sample dev container allows you to work with Kubernetes clusters and use the Kubernetes extension from within the container! 

The container includes the kubectl for Kubernetes, Helm, and the Docker CLI and can be easily set up to work with a local Minikube install. Just follow the steps below for your operating system.


## macOS Setup

1. Install "Docker Desktop for Mac" locally if you have not.

2. Start Docker, right-click on the Docker icon and select "Preferences..."

3. Check **Kubernetes > Enable Kubernetes**

4. Open this folder in VS Code

5. Edit `.vscode/devConatiner.json` and change `$HOME` in the last item in the `runArgs` array to the absolute path of your home folder. e.g.
    ```
    "runArgs": ["-e", "SYNC_LOCALHOST_KUBECONFIG=true",
        "-v","/var/run/docker.sock:/var/run/docker.sock", 
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

4. Open this folder in VS Code

5. Edit `.vscode/devConatiner.json` and change `$HOME` in the last item in the `runArgs` array to the absolute path of your home folder. e.g.
    ```
    "runArgs": ["-e", "SYNC_LOCALHOST_KUBECONFIG=true",
        "-v","/var/run/docker.sock:/var/run/docker.sock", 
        "-v", "/home/clantz/.kube:/root/.kube-localhost"]
    ```
    > **Note:** Resolving [vscode-remote#670](https://github.com/Microsoft/vscode-remote/issues/670) will remove this step.

6. Run the **Remote: Reopen folder in Container** command. Once connected, you should see your clusters in the Kubernetes explorer.

7. [Optional] If you want to use [Helm](https://helm.sh), open a VS Code terminal and run:
    ```
    helm init
    ```
