# Visual Studio Code Remote Development Container Definitions

A **development container** is a running Docker container that comes with a basic tool stack (Python, node, Go, etc.) and its prerequisites (e.g. `pylint` for Python). This container may be used to actually run an application or be focused exclusively on sandboxing tools, libraries, runtimes, or other utilities that need to be run against a codebase.

Visual Studio Code Remote allows you to open any folder inside (or mounted into) a dev container and take advantage of VS Code's full feature set. When using the capability, VS Code selectively runs certain extensions in the container to optimize your experience. The result is that VS Code can provide a local-quality development experience including full IntelliSense, debugging, and more regardless of where your code is hosted. 

**[See here to learn more about VS Code Remote](https://aka.ms/vscode-remote/docker)**.

This repository contains a set of **dev container definitions** made up of files like `devContainer.json` to help get you up and running in a containerized environment. These definitions describe the needed container image, any runtime arguments for starting the container, and any VS Code extensions that should be installed into it.

## Trying a definition

1. Click on one of the `containers` sub-folders to open it in your browser
2. Check out the README to see if there are any manual steps
3. Clone this repository or copy the contents of the folder to your machine
4. Run the **Remote: Open Folder in Container...** command in VS Code
5. Select the definition folder in the "open" dialog

Many definitions include a `test-project` that you can use to see the dev container in action. Note that if you open this folder locally instead, you'll be prompted to reopen it in a container as well. You can also use the **Remote: Reopen Folder in Container** command at any time.

## Using a definition

You can either:

- Run **Remote: Create Container Configuration File...** command in VS Code and pick a definition. The appropriate files will then be added to your project.

- Manually copy the contents of one of the `containers` sub-folders into your project. Copy the `.devcontainer` folder and `.vscode/devContainer.json` into your project and you should be ready to go!

### Can I just reuse an existing Docker configuration?

Absolutely! If you want to use an existing Dockerfile as a starting point, run **Remote-Docker: Create Container Configuraton File...** from the command pallette (Cmd/Ctrl+Shift+P). You'll be prompted to select a Dockerfile or you can opt to use a base image instead.

##### About `.vscode/devContainer.json`

The intent of `devContainer.json` is conceptually similar to VS Code's `launch.json` for debugging, but designed to launch (or attach to) your development container instead. At its simplest, all you need to do is add a `.vscode/devContainer.json` file to your project and reference an image, `Dockerfile`, or `docker-compose.yml`. 

Since you are here, check out the [Existing Dockerfile](containers/docker-existing-dockerfile) and [Existing Docker Compose](containers/docker-existing-docker-compose) definitions for details, but here's the a quick tour of the basic properties. If you have a `Dockerfile`, set these properties:

```json
{
    "name": "[Optional] Your project name here",
    "dockerFile": "Dockerfile"
}
```

Similarly, if you have a `docker-compose.yml` file, set these properties:

```json
{
    "name": "[Optional] Your project name here",
    "dockerComposeFile": "docker-compose.yml",
    "service": "the-name-of-the-service-you-want-to-work-with-in-vscode",
    "volume": "name-of-volume-where-source-code-is-located"
}
```
You may want to [extend your `docker-compose.yml` to avoid common pitfalls](containers/docker-existing-docker-compose).

The other definitions in the `containers` folder will provide examples of how to cover new scenarios you may encounter along the way. For example, you may want to [alter your configuration](https://aka.ms/vscode-remote/docker/folder-setup) to install additional tools like Git in the container, automatically install extensions, expose additional ports, or set runtime arguments. In other cases, you may just want to [attach to an already running container](https://aka.ms/vscode-remote/docker/attach). 

## Adding a definition to an existing public or private repo

You can easily share a customized dev container definition for your project by simply adding files like `.vscode/devContainer.json` to source control. By including these files in your repository, anyone that opens a local copy of your repo in VS Code will be automatically asked if they want reopen the folder in a container instead if the [Remote Development](https://aka.ms/vscode-remote/download/extension) extension installed.

You can also have VS Code prompt anyone opening your repo to install the Remote Development extension. Simply add the extension ID to `recommendations` array in `.vscode/extensions.json` (as described [here](https://code.visualstudio.com/docs/editor/extension-gallery#_workspace-recommended-extensions)) and then add the file to source control.

```json
{
    "recommendations": [
        "vscode.remotedevelopment"
    ]
}
```

Beyond the advantages of having your team use a consistent environment and tool-chain, doing this can make it easier for new contributors or team members to get productive quickly. First-time contributors will require less guidance and are less likely to either submit issues or contribute code with issues that are related to environment setup.

## Contents

- `containers` - Dev container definition folders. 
- `container-templates` - Templates for creating your own container definitions in your project or for contributing back to this repository.

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
