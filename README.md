# Visual Studio Code Remote Development Container Definitions

A **development container** is a running container that comes with a basic tool stack (Python, node, Go, etc.) and its prerequisites (e.g. `pylint` for Python). This container may be used to actually run an application or be focused exclusively on sandboxing tools, libraries, runtimes, or other utilities that need to be run against a codebase.The Containers extension in the [Visual Studio Code Remote Development](https://aka.ms/vscode-remote/download/extension) extension pack allows you to open any folder inside (or mounted into) a dev container and take advantage of VS Code's full feature set.

This repository contains a set of **dev container definitions** made up of files like `devcontainer.json` to help get you up and running in a containerized environment. These definitions describe the needed container image, any runtime arguments for starting the container, and any VS Code extensions that should be installed into it. They're can help you get started or as examples for adapting your own configuration to different situations.

**[Learn more!](https://aka.ms/vscode-remote/containers)**.

## Using a definition

You can either:

- Open a folder in VS Code without a `devcontainer.json` file and run the **Remote-Containers: Create Container Configuration File...** or **Remote-Containers: Reopen Folder in Container** commands. You be prompted to pick a definition and any options and the appropriate files will then be added to your project.

- Manually copy the contents of one of the `containers` sub-folders into your project. Typically you can just copy the `.devcontainer` folder into your project but the folder's README may mention additional files.

## Trying a definition

1. Click on one of the `containers` sub-folders to open it in your browser
2. Check out the `README` to see if there are any manual steps
3. Clone this repository or copy the contents of the folder to your machine
4. Run the **Remote-Containers: Open Folder in Container...** command in VS Code
5. Select the root of the definition folder in the "open" dialog (**not** the `test-project` folder if present)

Many definitions include a `test-project` with a sample and/or launch settings in the `.vscode` folder that you can use to see the dev container in action. See the `README` for how to use them.

## Adding a definition to an existing public or private repo

You can easily share a customized dev container definition for your project by simply adding files like `.devcontainer/devcontainer.json` to source control. By including these files in your repository, anyone that opens a local copy of your repo in VS Code will be automatically asked if they want reopen the folder in a container instead if the [Remote Development](https://aka.ms/vscode-remote/download/extension) extension installed.

Beyond the advantages of having your team use a consistent environment and tool-chain, doing this can make it easier for new contributors or team members to get productive quickly. First-time contributors will require less guidance and are less likely to either submit issues or contribute code with issues that are related to environment setup.

## Contents

- `containers` - Contains reusable dev container definitions.
- `container-templates` - Contains templates for creating your own container definitions for your project or to [contribute back](CONTRIBUTING.md#contributing-dev-container-definitions).
- `repository-containers` - Dev container definitions for working on a cloned copy of specific, public source code repository (rather than general purpose).

## Common Questions

### Can I just reuse an existing container image or Docker configuration?

Absolutely! If you want to use an existing Dockerfile as a starting point, run **Remote-Containers: Create Container Configuration File...** from the command pallette (Cmd/Ctrl+Shift+P). You'll be prompted to select a Dockerfile or you can opt to use a base image instead and customize from there.

You can also check out the [existing Dockerfile](containers/docker-existing-dockerfile) and [existing Docker Compose](containers/docker-existing-docker-compose) definitions for an example `devcontainer.json` . If none of these options meet your needs, you can start up the container any way you see fit and [attach to it](https://aka.ms/vscode-remote/containers/attach) instead.

### What is the goal of `devcontainer.json`?

The intent of `devcontainer.json` is conceptually similar to VS Code's `launch.json` for debugging, but designed to launch (or attach to) your development container instead. At its simplest, all you need to do is add a `.devcontainer/devcontainer.json` file to your project and reference an image, `Dockerfile`, or `docker-compose.yml` and a few properties.

Check out the `container-templates` folder for simple starter templates. The definitions in the `containers` folder can be used as-is or as samples for how to modify your existing config to support different scenarios. From there, you can [alter your configuration](https://aka.ms/vscode-remote/containers/folder-setup) to install additional tools like Git in the container, automatically install other extensions, expose additional ports, set runtime arguments, and more.

## Contributing & Feedback

Have a question or feedback? There are many ways to contribute.

- Contribute or provide feedback for the [VS Code Remote Development extensions](https://github.com/Microsoft/vscode-remote-release/CONTRIBUTING.md).
- Search [existing issues](https://github.com/Microsoft/vscode-dev-containers/issues) with dev container definitions or [report a problem](https://github.com/Microsoft/vscode-dev-containers/issues/new).
- Contribute a [development container definition](CONTRIBUTING.md#contributing-dev-container-definitions) to the repository.
- Contribute to [our documentation](https://github.com/Microsoft/vscode-docs) or [VS Code itself](https://github.com/Microsoft/vscode).
- ...and more. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## License

Copyright (c) Microsoft Corporation. All rights reserved. <br />
Licensed under the MIT License. See [LICENSE](LICENSE).
