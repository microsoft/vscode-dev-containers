# Hugo

## Summary

*Develop static sites with Hugo, includes everything you need to get up and running.*

|          Metadata           |                    Value                     |
| --------------------------- | -------------------------------------------- |
| *Contributors*              | [Aaryn Smith](https://gitlab.com/aarynsmith) |
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

## Using this definition with an existing folder

Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Hugo definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of this folder in the cloned repository to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
