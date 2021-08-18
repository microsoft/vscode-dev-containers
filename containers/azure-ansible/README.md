# Azure Ansible (Community)

## Summary

*Get going quickly with Ansible in Azure. Includes Ansible, the Azure CLI, the Docker CLI (for testing locally), Node.js for Cloud Shell, and related extensions and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Carlos Mendible](https://github.com/cmendible) |
| *Categories* | Community, Azure, Other |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Azure, Ansible |

## Using this definition

While technically optional, this definition includes the Ansible extension. You may need an Azure account for your operations. You can create a [free trial account here](https://azure.microsoft.com/en-us/free/) and find out more about using [Ansible with Azure here](https://docs.microsoft.com/en-us/azure/ansible/ansible-overview).

There are a few options you can pick from  by updating the following line in `.devcontainer/devcontainer.json`:

```jsonc
"arg": {
   "INSTALL_AZURE_CLI": "true",
   "INSTALL_DOCKER": "true",
   "NODE_VERSION": "lts"
}
```

If you plan to use the Azure Cloud Shell for all of your Ansible operations, you can set `"INSTALL_DOCKER": "false"`. Conversely, if you do not plan to use Cloud Shell, you can set `"NODE_VERSION": "none"`. By default, both are installed so you can decide later.

Beyond `git`, this `Dockerfile` includes `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**. 

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/main/LICENSE).
