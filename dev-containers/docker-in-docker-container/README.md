# Docker in Docker Container

When building an app that deploys into a container-based environment in production, you may want to sandbox your development using a dev container without sacrificing your ability build and deploy into separate Docker containers or take advantage of the [Docker](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) VS Code extension. This example illustrates how you can meet this need by using your local Docker Desktop installation from the `docker` CLI and [Docker](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) VS Code extension running inside a dev container.

While this will run example will run without any changes on macOS and Linux, there are **extra steps for Windows**.

## Windows Steps

1. Install "Docker Desktop for Windows" locally if you have not.
   
2. Right Click on Docker system tray icon and select "Settings"
   
3. Check **General > "Expose daemon on tcp://localhost:2375 without TLS"**
   
4. Wait for Docker to restart.
   
5. Open this folder in VS Code and modify the `runArgs` in `.vscode/devContainer.json` as follows:
   ```
    "runArgs": ["-e","DOCKER_HOST=tcp://host.docker.internal:2375"]
   ```
   > **Note:** Resolving [vscode-remote#669](https://github.com/Microsoft/vscode-remote/issues/669) will remove this step.

6. Run the **Remote: Reopen folder in Container** command
