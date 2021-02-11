# VS Code Remote / GitHub Codespaces Container Definitions

<table style="width: 100%; border-style: none;"><tr>
<td style="width: 140px; text-align: center;"><a href="https://aka.ms/vscode-remote/download/extension"><img width="128px" src="https://microsoft.github.io/vscode-remote-release/images/remote-extensionpack.png" alt="Visual Studio Code logo"/></a></td>
<td>
<strong>Visual Studio Code Remote Development and GitHub Codespaces</strong><br />
<i>Open your code in the cloud, in a local container, on a remote machine, or in WSL and take advantage of VS Code's full feature set.
</td>
</tr></table>

A **development container** is a running [Docker](https://www.docker.com) container with a well-defined tool/runtime stack and its prerequisites. The [VS Code Remote - Containers](https://aka.ms/vscode-remote/download/containers) extension allows you to clone a repository or open any folder mounted into (or already inside) a dev container and take advantage of VS Code's full development feature set. [GitHub Codespaces](https://github.com/features/codespaces) both use this same concept to quickly create customized, cloud-based development environments accessible [from VS Code](https://aka.ms/vso-dl) or the web.

This repository contains a set of **dev container definitions** to help get you up and running with a containerized environment. The definitions describe the appropriate container image, runtime arguments for starting the container, and VS Code extensions that should be installed. Each provides a container configuration file (`devcontainer.json`) and other needed files that you can drop into any existing folder as a starting point for containerizing your project.

The [vscode-remote-try-*](https://github.com/search?q=org%3Amicrosoft+vscode-remote-try-&type=Repositories) repositories may also be of interest if you are looking for complete sample projects.

## Adding a definition to a local project

To add a dev container definition in your project, you can either:

Manually add it to your project folder:

1. Clone this repository.
2. Copy the contents of the `.devcontainer` folder from of one of the definitions in the [`containers` folder](containers) to your project folder. 
3. See the definition's `README` for configuration details and options.
4. Open the folder [locally with the Remote - Containers extension](vscode-remote/containers/getting-started/open) or commit the file to source control to [use it with Codespaces](https://docs.github.com/en/github/developing-online-with-codespaces/configuring-codespaces-for-your-project#using-a-pre-built-container-configuration).

... or ...

Add it using VS Code Remote - Containers:
  
  1. [Set up your machine](https://aka.ms/vscode-remote/containers/getting-started) and then start VS Code and open your project folder.
  2. Press <kbd>F1</kbd>, select the **Remote-Containers: Add Development Container Configuration Files...** command, and pick one of definitions from the list. (You may need to choose the **From a predefined container configuration definition...** option if your project has an existing Dockerfile or Docker Compose file.)
  3. See the definition's `README` for configuration options. A link is available in the `.devcontainer/devcontainer.json` file added to your folder.
  4. Run **Remote-Containers: Reopen in Container** to use it locally, or commit the file to source control to [use it with Codespaces](https://docs.github.com/en/github/developing-online-with-codespaces/configuring-codespaces-for-your-project#using-a-pre-built-container-configuration).

### Adding a definition to a repository

You can share a customized dev container definition for your project by adding the files under `.devcontainer` to source control.

Anyone who then opens a local copy of your repo in VS Code will be prompted to reopen the folder in a container, provided they have the [Remote - Containers](https://aka.ms/vscode-remote/download/containers) extension installed.

Additionally, if you reference your Git repository when creating a codespace [GitHub Codespaces](https://github.com/features/codespaces), the container definition will be used.

Your team now has a consistent environment and tool-chain and new contributors or team members can be productive quickly. First-time contributors will require less guidance and there will be fewer issues related to environment setup.

## Sample projects

If you want to try a sample project which already has a dev container, check out one of the following repositories:

- [Node Sample](https://github.com/Microsoft/vscode-remote-try-node)
- [Python Sample](https://github.com/Microsoft/vscode-remote-try-python)
- [Go Sample](https://github.com/Microsoft/vscode-remote-try-go)
- [Java Sample](https://github.com/Microsoft/vscode-remote-try-java)
- [.NET Core Sample](https://github.com/Microsoft/vscode-remote-try-dotnetcore)
- [Rust Sample](https://github.com/microsoft/vscode-remote-try-rust)
- [C++ Sample](https://github.com/microsoft/vscode-remote-try-cpp)
- [PHP Sample](https://github.com/microsoft/vscode-remote-try-php)

## Contents

- [`containers`](containers) - Contains reusable dev container definitions.
- [`script-library`](script-library) - Includes scripts used in this repository to install things. Also useful in your own Dockerfiles.
- [`repository-containers`](repository-containers) - Dev container definitions for working public source code repositories.
- [`container-templates`](container-templates) - Contains templates for creating your own container definitions or to [contribute back](CONTRIBUTING.md#contributing-dev-container-definitions).

## Common Questions

### Can I just reuse an existing container image or Docker / Docker Compose configuration?

Yes, if you want to use an existing Dockerfile as a starting point, use the [Remote - Containers extension](https://aka.ms/vscode-remote/download/containers), open a folder, and then run **Remote-Containers: Add Development Container Configuration Files...** from the Command Palette (<kbd>F1</kbd>). You'll be prompted to select a Dockerfile or Docker Compose file and customize from there. If you then commit these files to a Git repository, you can use it with [GitHub Codespaces](https://github.com/features/codespaces) as well. If you prefer, you can also start up the container manually and [attach to it](https://aka.ms/vscode-remote/containers/attach).

### What is the goal of `devcontainer.json`?

A `devcontainer.json` file is similar to `launch.json` for debugging, but designed to launch (or attach to) a development container instead. At its simplest, all you need is a `.devcontainer/devcontainer.json` file in your project that references an image, `Dockerfile`, or `docker-compose.yml`, and a few properties. You can [adapt it for use](https://aka.ms/vscode-remote/containers/folder-setup) in a wide variety of situations.

### Why do Dockerfiles in this repo use `RUN` statements with commands separated by `&&`?

Each `RUN` statement creates a Docker image "layer". If one `RUN` statement adds temporary contents, these contents remain in this layer in the image even if they are deleted in a subsequent `RUN`. This means the image takes more storage locally and results in slower image download times if you publish the image to a registry. You can resolve this problem by using a `RUN` statement that includes any clean up steps (separated by `&&`) after a given operation. See [CONTRIBUTING.md](./CONTRIBUTING.md#why-do-dockerfiles-in-this-repository-use-run-statements-with-commands-separated-by-) for more tips.

## Contributing and feedback

Have a question or feedback?

- Contribute or provide feedback for the [VS Code Remote](https://github.com/Microsoft/vscode-remote-release/blob/master/CONTRIBUTING.md) extensions or [GitHub Codespaces](https://github.community/c/codespaces-beta).
- Search [existing issues](https://github.com/Microsoft/vscode-dev-containers/issues) with dev container definitions or [report a problem](https://github.com/Microsoft/vscode-dev-containers/issues/new).
- Contribute a [development container definition](CONTRIBUTING.md#contributing-dev-container-definitions) to the repository.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## License

Copyright (c) Microsoft Corporation. All rights reserved. <br />
Licensed under the MIT License. See [LICENSE](LICENSE).

For images generated from this repository, see [LICENSE](https://github.com/microsoft/containerregistry/blob/master/legal/Container-Images-Legal-Notice.md) and [NOTICE.txt](NOTICE.txt).
