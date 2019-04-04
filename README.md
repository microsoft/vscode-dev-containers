# Visual Studio Code Remote Development Container Definitions

A **development container** is a running container that comes with a basic tool stack (Python, node, Go, etc.) and its prerequisites (e.g. `pylint` for Python). This container may be used to actually run an application or be focused exclusively on sandboxing tools, libraries, runtimes, or other utilities that need to be run against a codebase.

The Containers extension in the [Visual Studio Code Remote Development](https://aka.ms/vscode-remote/download/extension) extension pack allows you to open any folder inside (or mounted into) a dev container and take advantage of VS Code's full feature set. When using the capability, VS Code selectively runs certain extensions in the container to optimize your experience. The result is that VS Code can provide a local-quality development experience including full IntelliSense, debugging, and more regardless of where your code is hosted.

**[Learn more about the Visual Studio Code Remote - Containers extension](https://aka.ms/vscode-remote/containers)**.

This repository contains a set of **dev container definitions** made up of files like `devcontainer.json` to help get you up and running in a containerized environment. These definitions describe the needed container image, any runtime arguments for starting the container, and any VS Code extensions that should be installed into it. They're can be useful to help you get started or as samples for how to adapt your own configuration to different situations.

## Trying a definition

1. Click on one of the `containers` sub-folders to open it in your browser
2. Check out the README to see if there are any manual steps
3. Clone this repository or copy the contents of the folder to your machine
4. Run the **Remote: Open Folder in Container...** command in VS Code
5. Select the root of the definition folder in the "open" dialog (**not** the `test-project` folder if present)

Many definitions include a `test-project` with a sample and/or launch settings in the `.vscode` folder that you can use to see the dev container in action. If you open the folder locally instead, you'll be prompted to reopen it in a container but uou can also use the **Remote: Reopen Folder in Container** command at any time.

## Using a definition

You can either:

- Run **Remote: Create Container Configuration File...** command in VS Code and pick a definition. The appropriate files will then be added to your project.

- Manually copy the contents of one of the `containers` sub-folders into your project. Copy the `.devcontainer` folder into your project and you should be ready to go!

## Adding a definition to an existing public or private repo

You can easily share a customized dev container definition for your project by simply adding files like `.devcontainer/devcontainer.json` to source control. By including these files in your repository, anyone that opens a local copy of your repo in VS Code will be automatically asked if they want reopen the folder in a container instead if the [Remote Development](https://aka.ms/vscode-remote/download/extension) extension installed.

Beyond the advantages of having your team use a consistent environment and tool-chain, doing this can make it easier for new contributors or team members to get productive quickly. First-time contributors will require less guidance and are less likely to either submit issues or contribute code with issues that are related to environment setup.

## Contents

- `containers` - Dev container definition folders. 
- `container-templates` - Templates for creating your own container definitions in your project or for contributing back to this repository.

## Common Questions

#### Can I just reuse an existing container image or Docker configuration?

Absolutely! If you want to use an existing Dockerfile as a starting point, run **Remote-Containers: Create Container Configuration File...** from the command pallette (Cmd/Ctrl+Shift+P). You'll be prompted to select a Dockerfile or you can opt to use a base image instead and customize from there. 

You can also check out the [existing Dockerfile](containers/docker-existing-dockerfile) and [existing Docker Compose](containers/docker-existing-docker-compose) definitions for an example. You can also [attach to an already running container](https://aka.ms/vscode-remote/containers/attach) if you'd prefer.

##### What is the goal of `devcontainer.json`?

The intent of `devcontainer.json` is conceptually similar to VS Code's `launch.json` for debugging, but designed to launch (or attach to) your development container instead. At its simplest, all you need to do is add a `.devcontainer/devcontainer.json` file to your project and reference an image, `Dockerfile`, or `docker-compose.yml` and a few properties.

Check out the `container-templates` folder for simple examples. The definitions in the `containers` folder can be used as-is or as samples for how to modify your existing config to support different scenarios. From there, you can [alter your configuration](https://aka.ms/vscode-remote/containers/folder-setup) to install additional tools like Git in the container, automatically install other extensions, expose additional ports, set runtime arguments, and more.

### Are development containers intended to define how an application is deployed?

No. A development container is an environment that you can use to develop your application even before you are ready to build or deploy. While deployment and development containers may resemble one another, you often will not include tools in a deployment image that you will want during development. The set of "dev container definitions" found in the [vscode-dev-containers repo](https://aka.ms/vscode-dev-containers) are intended to help jump start the process of creating a development container by including a set of well-known container build or deployment files and a `devcontainer.json` file. This file provides a home for tooling and edit-time related settings and a pointer to the image (or files that define the image) that should be used for the development container. However, their use is entirely optional, and you can [attach to a running container](https://aka.ms/vscode-remote/attach) in other container-based workflows and scenarios.

### Are development containers intended to define how an application is built? Like Buildpacks?

No. The [Buildpack](https://buildpacks.io/) concept focuses on taking source code and generating deployable container images through a series of defined steps. A dev container is an environment you can use to develop your application even before you are ready to build. They are therefore complementary concepts. The `devcontainer.json` file is not intended to define how your application should be built, but rather provides a home for tooling and edit-time related settings and a pointer to an image or image definition files. Today it supports pointing to an existing image (which could be generated by a Buildpack), a Dockerfile, or one or more `docker-compose.yml` files, but more will be added as the community has interest. You can also opt to [attach to a running container](https://aka.ms/vscode-remote/attach) if you prefer to use an alternate container build or deployment workflow.

Similarly, the "dev container definitions" found in the [vscode-dev-containers repo](https://aka.ms/vscode-dev-containers) can help jump start the process of creating a dev container when you do not have an existing image, `Dockerfile`, or `docker-compose.yml`. These can also act as samples if you do have existing container files. However, they are not intended to define how an application should be built.

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
