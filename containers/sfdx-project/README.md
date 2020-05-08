# SFDX Project

## Summary

Salesforce Extension for VS Code supports remote development and allows you to use a docker container as a full-featured development environment.

| Metadata | Value |  
|----------|-------|
| *Contributors* | Salesforce Developer Experience Teams  |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, Platforms* | Salesforce CLI, Lightning Web Components, Apex, Aura, Java, Node.js, JavaScript, HTML, CSS, Git |

## Description

Remote development in container environment is powered by the official Salesforce sfdx [image](https://hub.docker.com/r/salesforce/salesforcedx) on Docker Hub. Salesforce CLI, Java, node.js, and Git are pre-installed and configured in your container. You can open a project mounted into the container and edit with full IntelliSense (completions), code navigation, debugging, and more.

You can learn more about remote development with Salesforce Extension [here](https://forcedotcom.github.io/salesforcedx-vscode/).

## Using this definition with an existing folder

Just follow these steps:

1. If this is your first time using a development container, follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> and run **Remote-Containers: Add Development Container Configuration Files...** from the Command Palette.
   3. Select the Salesforce Project definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of this folder in the cloned repository to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After step 2 or 3, edit the contents of the `.devcontainer` folder in your project, as required.

5. Start using the definition by running **Remote-Containers: Reopen Folder in Container** from the Command Palette.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
