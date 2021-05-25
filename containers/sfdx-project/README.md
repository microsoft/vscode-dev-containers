# SFDX Project (Community)

## Summary

Salesforce Extension for VS Code supports remote development and allows you to use a docker container as a full-featured development environment.

| Metadata | Value |  
|----------|-------|
| *Contributors* | Salesforce Developer Experience Teams |
| *Categories* | Community, Services |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Ubuntu |
| *Languages, Platforms* | Salesforce CLI, Lightning Web Components, Apex, Aura, Java, Node.js, JavaScript, HTML, CSS, Git |

## Description

Remote development in container environment is powered by the official Salesforce sfdx [image](https://hub.docker.com/r/salesforce/salesforcedx) on Docker Hub. Salesforce CLI, Java, node.js, and Git are pre-installed and configured in your container. You can open a project mounted into the container and edit with full IntelliSense (completions), code navigation, debugging, and more.

You can learn more about remote development with Salesforce Extension [here](https://forcedotcom.github.io/salesforcedx-vscode/).

## Using this definition

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
