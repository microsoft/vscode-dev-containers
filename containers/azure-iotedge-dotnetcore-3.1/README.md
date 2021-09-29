# Azure IoTEdge & C# - .NET Core 3.1

## Summary

*Develop Azure IoTedge Solutions in C#. Includes NET Core 3.1, the device CSharp SDK, and related extensions and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The Azure IoT Device Experience Team, @mhshami01 |
| *Categories* | Devices, Azure |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | CSharp Device SDK, .NET Core, C# |

## Using this definition

This definition requires an Azure subscription to use. You can create a [free account here](https://azure.microsoft.com/en-us/free/serverless/). Once you have an Azure account, You can learn more about [Azure IoT Edge](https://docs.microsoft.com/en-us/azure/iot-edge/about-iot-edge?view=iotedge-2020-11) and how to [Develop Custom Modules with Visual Studio Code](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-vs-code-develop-module?view=iotedge-2020-11). Once you have an IoT Edge device setup, follow these steps:

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**. 

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/azure-functions-dotnetcore-3.1` folder.
5. After the folder has opened in the container, press <kbd>F1</kbd> and select **Azure IoT Edge: New IoT Edge Solution...**.
6. Enter these options:
   1. Specify the folder where you wish your new solution to be setup and click <kbd>OK</kbd>
   2. Provide a Solution Name (Press <kbd>Enter</kbd> for the default name *EdgeSolution*)
   3. C# Module
   4. Provide a Module Name (Press <kbd>Enter</kbd> for the default name *SampleModule*)
   5. Provide Docker Image Repository for the Module (Press <kbd>Enter</kbd> to select the default option)
7. Learn how to [Develop Custom Modules with Visual Studio Code](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-vs-code-develop-module?view=iotedge-2020-11).

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
