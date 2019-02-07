# Docker in Docker Container

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into your local Docker Desktop instance without affecting your dev container. This example illustrates how you can do this by running CLI commands and using the [Docker VS Code extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) right from inside your dev container.

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
