# Kubernetes - K3d-in-Docker

## Summary

*Access an embedded k3d instance or remote a Kubernetes cluster from inside a dev container. Includes kubectl, Helm, k3d, and Docker.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code team |
| *Categories* | Other |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Any |

## Description

> **Note:** If you're looking to reuse a local Kubernetes instance from Remote - Containers, you may find the [Kubernetes - Local Configuration](../kubernetes-helm) definition more interesting.

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into a local k3d or remote [Kubernetes](https://kubernetes.io/) cluster without affecting your dev container.

This example illustrates how you can do this by using CLIs ([kubectl](https://kubernetes.io/docs/reference/kubectl/overview/), [Helm](https://helm.sh), Docker), the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools), and the [Docker extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) right from inside your dev container.  This definition builds up from the [docker-in-docker](../docker-in-docker) container definition along with a [k3d](https://k3d.io/) installation that can run right inside the container. It installs the Docker and Kubernetes extensions inside the container so you can use its full feature set with your project.

## Using this definition with an existing folder

A few notes on the definition:

* The included `.devcontainer/Dockerfile` can be altered to work with other Debian/Ubuntu-based container images such as `node` or `python`. Just, update the `FROM` statement to reference the new base image. For example:

    ```Dockerfile
    FROM node:lts
    ```

* If you want k3d to automatically start when the dev container starts, uncomment the following line:

    ```json
    "postStartCommand": "k3d cluster create > k3d.log 2>&1",
    ```

    This will log k3d output to `k3d.log` in your workspace folder, but you can update that part of the line above to a different path if you wish (e.g. `/tmp/k3d.log`).

Beyond that, just follow these steps to use the definition:

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Getting started with Kubernetes Deployments

Deploy an application into the local k3d cluster or remote kubernetes cluster by creating a Kubernetes Deployment object.

```bash

# Create a Deployment based on the YAML file
kubectl apply -f https://k8s.io/examples/application/deployment.yaml

# Display information about the Deployment
kubectl describe deployment nginx-deployment

# List the Pods created by the deployment
kubectl get pods -l app=nginx

# Delete the deployment by name
kubectl delete deployment nginx-deployment

```

Refer to the [Kubernetes documentation](https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/) for a detailed walkthrough on deploying applications to a Kubernetes cluster.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
