# Azure Ansible

## Summary

*Get going quickly with Ansible in Azure. Includes Ansible, the Azure CLI, the Docker CLI (for testing locally), Node.js for Cloud Shell, and related extensions and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Carlos Mendible](https://github.com/cmendible) |
| *Definition type* | Dockerfile |
| *Languages, platforms* | Ansible |

## Using this definition with an existing folder

While technically optional, this definition includes the Ansible extension. You may need an Azure account for your operations. You can create a [free trial account here](https://azure.microsoft.com/en-us/free/) and find out more about using [Ansible with Azure here](https://docs.microsoft.com/en-us/azure/ansible/ansible-overview).  If you plan to use the Azure Cloud Shell for all of your Ansible operations, you can comment out the installation of the Docker CLI in `.devcontainer/Dockerfile`. Conversely, if you do not plan to use Cloud Shell, you can comment out the installation of Node.js. The definition has been setup so you can do either as it makes sense.

Next, follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Azure Ansible definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/azure-ansible/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
