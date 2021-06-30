# Existing Dockerfile

## Summary

*Sample illustrating reuse of an existing Dockefile.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code team |
| *Categories* | Core, Other |
| *Definition type* | Dockerfile |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Any |

> **Note:** There is also a [Docker Compose](../docker-existing-docker-compose) variation of this same definition.

## Using this definition

This definition requires an existing `Dockerfile` in your project and outlines some settings in `.devcontainer/devcontainer.json` to consider when reusing one.

Follow these steps to use it:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Existing Dockerfile definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/docker-existing-dockerfile/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, review the settings and comments in the `.devcontainer/devcontainer.json` file added to your project. Comments in the file will help you expose new ports, install extensions, forward the Docker socket, and more.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE). 
