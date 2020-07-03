# Deno

## Summary

*Develop Deno applications. Includes the latest Deno runtime and extension.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | anthonychu |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Deno, TypeScript, JavaScript |

## Using this definition with an existing folder

This definition doesn't require any special steps to use. Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

1. To use VS Code's copy of this definition:
    1. Start VS Code and open your project folder.
    1. Press <kbd>F1</kbd> and select **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
    1. Select the **Deno** definition.
        - If necessary, first select **Show All Definitions...**.

1. To use latest-and-greatest copy of this definition from the repository:
    1. Clone this repository.
    1. Copy the contents of `containers/deno/.devcontainer` to the root of your project folder.
    1. Start VS Code and open your project folder.

1. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

1. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen in Container** to start using the definition.

## Testing the definition

To verify the definition is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
1. Clone this repository.
1. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
1. Select the `containers/deno` folder.
1. After the folder has opened in the container, press <kbd>Ctrl-Shift-`</kbd> to open a new terminal.
1. Run the following command to execute a simple application.
    ```bash
    deno run -A https://deno.land/std@0.57.0/examples/welcome.ts
    ```
1. You should see "Welcome to Deno 🦕" in the Debug Console after the program executes.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).