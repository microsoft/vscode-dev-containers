# Docker in Docker Container

This example has a dev container that actually contains the Docker CLI. This allows you to use the Docker extension and run docker commands from within a dev container that can still control, interact with, and deploy to your local OS Docker install!

While this will run out-of-box on macOS and Linux, there is an extra **step for Windows**.

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

6. Run the **Remote: Reopen folder in Container"** command
