# Java 11

## Summary

*Develop Java 11 applications. Includes JDK 11 and Java extensions.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Java Team |
| *Definition type* | Dockerfile |
| *Languages, platforms* | Java |

## Using this definition with an existing folder

Note that only the integrated terminal is supported by the Remote - Containers extension. You may need to modify `launch.json` configurations to include the following value if an external console is used.

```json
"console": "integratedTerminal"
```

Beyond that, just follow these steps to use the definition:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Create Container Configuration File...** from the command palette.
   3. Select the Java 11 definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/java-11/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

6. If you want to include maven or gradle build tools into your dev container, please uncomment the corresponding steps from the `containers/java-11/.devcontainer/Dockerfile`, and run **Remote-Containers: Rebuild Container** to rebuild the dev container.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/java-11` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "Hello Remote World!" in the a Debug Console after the program executes.
7. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
