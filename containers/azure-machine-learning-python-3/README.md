# Azure Machine Learning & Python 3 - Anaconda

## Summary

*Use Azure Machine Learning with Python 3 - Anaconda. Includes Anaconda, the Docker CLI (for local testing), and related extensions and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Categories* | Services, Azure |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Azure Machine Learning, Python, Anaconda |

## Using this definition

There are a few notes for using this definition:

1. This definition requires an Azure subscription to use. You can create a [free account here](https://account.azure.com/signup?offer=ms-azr-0044p&appId=102&ref=azureplat-generic&redirectURL=https%3a%2f%2fazure.microsoft.com%2fen-us%2fget-started%2fwelcome-to-azure%2f&l=en-us&correlationId=15FE63BE1C4960F42D1B6EFB18496296) and learn more about using [Azure Machine Learning with VS Code here](https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-vscode-tools#get-started-with-azure-machine-learning).

2. The definition also uses an Anaconda base image which can take some time to download the first time given its size.

3. If you are using Docker locally in your `runconfig`, you will need to set `sharedVolumes` to `false` since these will not work from inside a dev container.

Once you have an Azure account, follow these steps:

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**. 

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
