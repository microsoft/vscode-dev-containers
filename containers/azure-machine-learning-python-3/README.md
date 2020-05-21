# Azure Machine Learning & Python 3 - Anaconda

## Summary

*Use Azure Machine Learning with Python 3 - Anaconda. Includes Anaconda, the Docker CLI (for local testing), and related extensions and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Azure Machine Learning, Python, Anaconda |

## Using this definition with an existing folder

There are a few notes for using this definition:

1. This definition requires an Azure subscription to use. You can create a [free account here](https://account.azure.com/signup?offer=ms-azr-0044p&appId=102&ref=azureplat-generic&redirectURL=https%3a%2f%2fazure.microsoft.com%2fen-us%2fget-started%2fwelcome-to-azure%2f&l=en-us&correlationId=15FE63BE1C4960F42D1B6EFB18496296) and learn more about using [Azure Machine Learning with VS Code here](https://docs.microsoft.com/en-us/azure/machine-learning/service/how-to-vscode-tools#get-started-with-azure-machine-learning).

2. The definition also uses an Anaconda base image which can take some time to download the first time given its size.

3. If you are using Docker locally in your `runconfig`, you will need to set `sharedVolumes` to `false` since these will not work from inside a dev container.

Once you have an Azure account, follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Azure Machine Learning definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/azure-machine-learning-python-3/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
