# Dart

## Summary

*Develop Dart based applications. Includes the Dart SDK, needed extensions, and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Definition type* | Dockerfile |
| *Languages, platforms* | Dart |

## Using the definition with an existing folder

This definition does not have any special setup requirements, so follow these steps to use it:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Create Container Configuration File...** from the command palette.
   3. Select the Dart definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/dart/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. Modify the contents of the `.devcontainer` folder added to your project as needed.
5. Press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to use it.

## Testing the definition

This definition includes some test code that you can use to verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/dart` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project. This will automatically run `pub get` and build the code be for starting it.
6. Once the project is running, press <kbd>F1</kbd> and select **Remote-Containers: Forward Port...**
7. Select port 8080 and open `http://localhost:8080` in a browser.
8. From here, you can add breakpoints or edit the contents of the `test-project` folder for further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](../../LICENSE).
