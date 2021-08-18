# Existing Docker Compose (Extend)

## Summary

*Sample illustrating how to extend an existing Docker Compose file for use in a dev container.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code team |
| *Categories* | Core, Other |
| *Definition type* | Docker Compose |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Any |

> **Note:** There is also a single [Dockerfile](../docker-existing-dockerfile) variation of this same definition.

## Using this definition

This definition requires an existing `docker-compose.yml` file that you would prefer not to modify but still want to add additional ports, a volume mount, or override the default command so that the container does not shut down if you stop the application.  The `.devcontainer/docker-compose.yml` and `.devcontainer/devcontainer.json` file will needs to be modified for your scenario.

Follow these steps to use it:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Existing Docker Compose (Extend) definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the `containers/docker-existing-docker-compose/.devcontainer` folder to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, you will need to modify the following files in `.devcontainer` folder that was added to your project:
   1. Update `your-service-name-here` in both the `docker-compose.yml` file and `devcontainer.json` to the name of the service you want to extend.
   2. Update the `volume` mapping in `docker-compose.yml` to point to your source code location and the `workspacePath` in `devcontainer.json` to match it.
   3. Each file has some information on additional settings to consider.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE)
