# Elm

## Summary

*Develop Elm based applications. Includes the Elm language server extension & binary*

| Metadata | Value |  
|----------|-------|
| *Contributors* | xWiiLLz, @andys8 |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Elm |

## Using this definition with an existing folder

This definition does not require any special steps to use. Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the **Elm** definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/elm/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

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

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
