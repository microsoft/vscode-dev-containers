# Bun (Community)

## Summary

_Develop Bun applications. Includes the latest Bun runtime and extension._

| Metadata                    | Value                        |
| --------------------------- | ---------------------------- |
| _Contributors_              | @bherbruck                   |
| _Categories_                | Community, Languages         |
| _Definition type_           | Dockerfile                   |
| _Supported architecture(s)_ | x86-64                       |
| _Works in Codespaces_       | Yes                          |
| _Container host OS support_ | Linux, macOS, Windows        |
| _Container OS_              | Debian                       |
| _Languages, platforms_      | Bun, TypeScript, JavaScript  |

## Using this definition

1. If this is your first time using a development container, please see getting
   started information on
   [setting up](https://aka.ms/vscode-remote/containers/getting-started)
   Remote-Containers or
   [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub
   Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration
   Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from
   > this sub-folder in a locally cloned copy of this repository into the VS
   > Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All
   Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in
   Container** or **Codespaces: Rebuild Container** to start using the
   definition.

## Testing the definition

To verify the definition is working as expected on your system. Follow these
steps:

1. If this is your first time using a development container, please follow the
   [getting started steps](https://aka.ms/vscode-remote/containers/getting-started)
   to set up your machine.
1. Clone this repository.
1. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open
   Folder in Container...**
1. Select the `containers/bun` folder.
1. After the folder has opened in the container, press <kbd>Ctrl-Shift-`</kbd>
   to open a new terminal.
1. Run the following command to execute a simple application.

   ```bash
   bun
   ```

1. You should see "bun: a fast bundler, transpiler, JavaScript Runtime and package manager for web software." in the terminal.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See
[LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
