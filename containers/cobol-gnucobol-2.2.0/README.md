# COBOL (Community)

## Summary

*A devcontainer to compile and run COBOL with GnuCOBOL*

| Metadata                    | Value                                                                        |
|---------------------------- | -----------------------------------------------------------------------------|
| *Contributors*              | Eloy López,  [github.com/elswork](https://github.com/elswork)                |
| *Categories*                | Community, Languages                                                         |
| *Definition type*           | Dockerfile                                                                   |
| *Works in Codespaces*       | Yes                                                                          |
| *Container host OS support* | Linux, macOS, Windows                                                        |
| *Container OS*              | Debian                                                                       |
| *Languages, platforms*      | COBOL                                                                        |

### Adding the definition to a project or codespace

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
4. Select this folder from the cloned repository.
5. There is a hello world sample included (`main.cbl`) to verify your dev container is working. Follow the steps below to try it.

### Compile

Once the container is up and running, open container terminal and execute:

```
cobc -x main.cbl
```

### Run

If the compilation is successful, you can run the sample program with: 

```
./main
```


## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/main/LICENSE).