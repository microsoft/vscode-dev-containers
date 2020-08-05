# Kubernetes and Helm

## Summary

*Access a local (or remote) Kubernetes cluster from inside a dev container. Includes kubectl, Helm, and the Docker CLI.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code team and Phetsinorath William |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Any |

## Description

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into a local or remote [Kubernetes](https://kubernetes.io/) cluster without affecting your dev container.

This example illustrates how you can do this by using CLIs ([kubectl](https://kubernetes.io/docs/reference/kubectl/overview/), [Helm](https://helm.sh), Docker), the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools), and the [Docker extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) right from inside your dev container.  This definition builds up from the [docker-from-docker](../docker-from-docker) container definition to add Kubernetes and Helm support.  It installs the Docker and Kubernetes extensions inside the container so you can use its full feature set with your project.

The dev container also syncs your local Kubernetes config (`~/.kube/config` or `%USERPROFILE%\.kube\config`) into the container with the necessary modifications to allow it to interact with anything running on your local machine whenever the container or a terminal window is started. This includes interacting with a Kubernetes cluster managed through Docker Desktop or a local Minikube install.

## How it works / adapting your existing dev container config

The [`.devcontainer` folder in this repository](.devcontainer) contains a complete example that **you can simply change the `FROM` statement** to another Debian/Ubuntu based image to adapt to your own use (along with adding anything else you need).

However, this section will outline the how you can selectively add this functionality to your own Dockerfile in two parts: installing kubectl and enabling access to Docker for the root user, and enabling it for a non-root user.

### Setting up kubectl and enabling root user access to Docker in the container

You can adapt your own existing development container Dockerfile to support this scenario by following these steps:

1. First, update your `devcontainer.json` to forward the local Docker socket and mount the local `.kube` folder in the container so its contents can be reused. From `.devcontainer/devcontainer.json`:

    ```json
    "mounts": [
        "source=/var/run/docker.sock,target=/var/run/docker.sock",
        "source=${env:HOME}${env:USERPROFILE}/.kube,target=/usr/local/share/kube-localhost,type=bind"
    ],
    "remoteEnv": {
        "SYNC_LOCALHOST_KUBECONFIG": "true"
    }
    ```

    If you also want to reuse your Minikube certificates, just add a mount for your local `.minikube` folder as well:

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

2. Next, update your Dockerfile to install all of the needed CLIs in the container:

    ```Dockerfile
    # Install Docker CE CLI
    RUN apt-get update \
        && apt-get install -y apt-transport-https ca-certificates curl gnupg2 lsb-release \
        && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
        && echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
        && apt-get update \
        && apt-get install -y docker-ce-cli

    # Install kubectl
    RUN curl -sSL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
        && chmod +x /usr/local/bin/kubectl

    # Install Helm
    RUN curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -
    ```

3. Finally, we need to automatically swap out `localhost` for `host.docker.internal` in the container's copy of the Kubernetes config and (optionally) Minikube certificates. Manually copy the [`copy-kube-config.sh` script](.devcontainer/copy-kube-config.sh) from the `.devcontainer` folder in this repo folder into the same folder as your `Dockerfile` and then update your `Dockerfile` to use it from your `/root/.bashrc` and/or `/root/.zshrc`. 

    ```Dockerfile
    COPY copy-kube-config.sh /usr/local/share/
    RUN echo "source /usr/local/share/copy-kube-config.sh" | tee -a /root/.bashrc >> /root/.zshrc
    ```

4. Press <kbd>F1</kbd> and run **Remote-Containers: Rebuild Container** so the changes take effect.

### Enabling non-root access in the container

To enable non-root access, you can use `socat` to proxy the Docker socket without affecting its permissions. This is safer than updating the permissions of the host socket itself since this would apply to all containers. You then also need to copy the `.bashrc` script into the non-root user's home folder as well.

Follow these directions to set up non-root access using `socat`:

1. Follow [the instructions in the Remote - Containers documentation](https://aka.ms/vscode-remote/containers/non-root) to create a non-root user with sudo access if you do not already have one.

2. Follow the [directions in the previous section](#setting-up-kubectl-and-enabling-root-user-access-to-docker-in-the-container) to install the Docker CLI, kubectl, and Helm.

3. Update your `devcontainer.json` to mount the Docker socket to `docker-host.sock` in the container and enable the non-root user:

    ```json
    "mounts": [
        "source=/var/run/docker.sock,target=/var/run/docker-host.sock,type=bind",
        //..
    ],
    "overrideCommand": false,
    "remoteUser": "vscode"
    ```

4. Next, tweak the `.bashrc` script and and add some other steps in your `Dockerfile` to wire up `socat`:

    ```Dockerfile
    ARG NONROOT_USER=vscode

    COPY copy-kube-config.sh /usr/local/share/
    RUN chown ${NONROOT_USER}:root /usr/local/share/copy-kube-config.sh \
        && echo "source /usr/local/share/copy-kube-config.sh" | tee -a /root/.bashrc /root/.zshrc /home/${NONROOT_USER}/.bashrc >> /home/${NONROOT_USER}/.zshrc

    # Default to root only access to the Docker socket, set up non-root init script
    RUN touch /var/run/docker.socket \
        && ln -s /var/run/docker-host.socket /var/run/docker.socket
        && apt-get update \
        && apt-get -y install socat

    # Create docker-init.sh to spin up socat
    RUN echo "#!/bin/sh\n\
        sudo rm -rf /var/run/docker-host.socket\n\
        ((sudo socat UNIX-LISTEN:/var/run/docker.socket,fork,mode=660,user=${NONROOT_USER} UNIX-CONNECT:/var/run/docker-host.socket) 2>&1 >> /tmp/vscr-dind-socat.log) & > /dev/null\n\
        \"\$@\"" >> /usr/local/share/docker-init.sh \
        && chmod +x /usr/local/share/docker-init.sh

    # Setting the ENTRYPOINT to docker-init.sh will configure non-root access to
    # the Docker socket if "overrideCommand": false is set in devcontainer.json.
    # The script will also execute CMD if you need to alter startup behaviors.
    ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
    CMD [ "sleep", "infinity" ]
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

4. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Docker from Docker Compose definition.

5. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/kubernetes-helm/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

6. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

7. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

### Linux / Minikube Setup

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
   3. Select the Docker from Docker Compose definition.

5. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/kubernetes-helm/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

6. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

7. Open `.devcontainer/devcontainer.json` and uncomment this line in the `runArgs` array:

    ```json
    "--mount", "type=bind,source=${env:HOME}${env:USERPROFILE}/.minikube,target=/usr/local/share/minikube-localhost",
    ```

8. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE). 
