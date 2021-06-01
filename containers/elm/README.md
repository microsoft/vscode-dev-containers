# Elm (Community)

## Summary

*Develop Elm based applications. Includes the Elm language server extension & binary*

| Metadata | Value |  
|----------|-------|
| *Contributors* | xWiiLLz, @andys8 |
| *Categories* | Community, Languages |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Elm |

## Using this definition

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
4. Select the `containers/elm` folder.
5. After the folder has opened in the container, open a terminal in the `test-project` folder (`cd test-project/`) and run the following command: `elm reactor`
6. Once the project is running, press <kbd>F1</kbd> and select **Remote-Containers: Forward Port from Container...**
7. Select port 8000 and click the "Open Browser" button in the notification that appears.
8. You should see the Elm startup page.
9. From here, you can browse any of the files in the `examples` folder to see them compiled and ran in your browser 😊

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
