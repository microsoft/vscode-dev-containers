# Hugo

## Summary

*Develop static sites with Hugo, includes everything you need to get up and running.*

|          Metadata           |                    Value                     |
| --------------------------- | -------------------------------------------- |
| *Contributors*              | [Aaryn Smith](https://gitlab.com/aarynsmith) |
| *Categories*                | Community, Frameworks                        |
| *Definition type*           | Dockerfile                                   |
| *Works in Codespaces*       | Yes                                          |
| *Container host OS support* | Linux, macOS, Windows                        |
| *Container OS*              | Debian                                       |
| *Languages, platforms*      | Hugo                                         |

This development container includes the Hugo static site generator as well as Node.js (to help with working on themes).

There are 3 configuration options in the `devcontainer.json` file:

- `VARIANT`: the default value is `hugo`. Set this to `hugo_extended` if you want to use SASS/SCSS
- `VERSION`: version of Hugo to download, e.g. `0.71.1`. The default value is `latest`, which always picks the latest version available.
- `NODE_VERSION`: version of Node.js to use, for example `14` (the default value)

The `.vscode` folder additionally contains a sample `tasks.json` file that can be used to set up Visual Studio Code [tasks](https://code.visualstudio.com/docs/editor/tasks) for working with Hugo sites.

## Using this definition

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
