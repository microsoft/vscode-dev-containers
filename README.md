# VS Code Remote Development Container Definitions

<table style="width: 100%; border-style: none;"><tr>
<td style="width: 140px; text-align: center;"><a href="https://aka.ms/vscode-remote/download/extension"><img width="128px" src="https://microsoft.github.io/vscode-remote-release/images/remote-extensionpack.png" alt="Visual Studio Code logo"/></a></td>
<td>
<strong>Visual Studio Code Remote Development</strong><br />
<i>Open any folder in a container, on a remote machine, or in WSL and take advantage of VS Code's full feature set. <strong><a href="https://aka.ms/vscode-remote">Learn more!</a></strong><br />
<strong><a href="https://aka.ms/vscode-remote/download/extension"><img src="https://microsoft.github.io/vscode-remote-release//images/download.png" alt="Download now!"/></a></strong></i>
</td>
</tr></table>

A **development container** is a running container with a well defined tool and runtime stack and their prerequisites. The Remote - Containers extension in the [Remote Development](https://aka.ms/vscode-remote/download/extension) extension pack allows you to open any folder inside (or mounted into) a dev container and take advantage of VS Code's full feature set.

This repository contains a set of **dev container definitions** to help get you up and running in a containerized environment. They describe the needed container image, any runtime arguments for starting the container, and any VS Code extensions that should be installed into it. They're can help you get started or be used as examples for adapting your own configuration to different situations.

## Using a definition

To add a dev container definition in your project, you can either:

- Add them using VS Code:
  
  1. If this is your first time creating a dev container, follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to configure your machine.
  2. Start VS Code and open your project folder.
  3. Press <kbd>F1</kbd>
  and select either the **Remote-Containers: Create Container Configuration File...** or **Remote-Containers: Reopen Folder in Container** commands. 
  4. Follow the directions and pick a development container definition when the list appears.

- Or manually copy the contents of one of folders in the `containers` directory into your project. Typically you can just copy the `.devcontainer` folder ignore everything else. See the definition's `README` for details.

## Testing a definition

If you want to test a definition before choosing one:

1. If this is your first time creating a dev container, follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to configure your machine.
2. Browse the contents of the  `containers` folder in this repository and pick one. Check out the `README` to see if there are any manual setup steps you should be aware of before continuing.
3. Clone this repository locally.
4. Start VS Code, press <kbd>F1</kbd>, and run the **Remote-Containers: Open Folder in Container...** command.
5. Select the root of the definition folder from the cloned repository when prompted (**not** the `test-project` folder if present).
6. See the definition's `README` for what to do next.

## Sample Projects

If you're looking to try a sample project rather than information on setting up a dev container, check out one of the following repositories:

- [Node Sample](https://github.com/Microsoft/vscode-remote-try-node)
- [Go Sample](https://github.com/Microsoft/vscode-remote-try-go)
- [Java Sample](https://github.com/Microsoft/vscode-remote-try-java)
- [PHP Sample](https://github.com/Microsoft/vscode-remote-try-php)
- [Python Sample](https://github.com/Microsoft/vscode-remote-try-python)
- [Ruby Sample](https://github.com/Microsoft/vscode-remote-try-ruby)
- [Rust Sample](https://github.com/Microsoft/vscode-remote-try-rust)
- [.NET Core Sample](https://github.com/Microsoft/vscode-remote-try-dotnetcore)


## Adding a definition to an existing public or private repo

You can easily share a customized dev container definition for your project by simply adding files like `.devcontainer/devcontainer.json` to source control. By including these files in your repository, anyone that opens a local copy of your repo in VS Code will be automatically asked if they want reopen the folder in a container instead if the [Remote Development](https://aka.ms/vscode-remote/download/extension) extension installed.

Beyond the advantages of having your team use a consistent environment and tool-chain, doing this can make it easier for new contributors or team members to get productive quickly. First-time contributors will require less guidance and are less likely to either submit issues or contribute code with issues that are related to environment setup.

## Contents

- `containers` - Contains reusable dev container definitions.
- `container-templates` - Contains templates for creating your own container definitions for your project or to [contribute back](CONTRIBUTING.md#contributing-dev-container-definitions).
- `repository-containers` - Dev container definitions for working on a cloned copy of specific, public source code repository (rather than general purpose).

### Common Questions

#### Can I just reuse an existing container image or Docker / Docker Compose configuration?

Yes! If you want to use an existing Dockerfile as a starting point, run **Remote-Containers: Create Container Configuration File...** from the command pallette (Cmd/Ctrl+Shift+P). You'll be prompted to select a Dockerfile or Docker Compose file and customize from there. If you prefer, you can also you can start up the container any way you see fit and [attach to it](https://aka.ms/vscode-remote/containers/attach) instead.

#### What is the goal of `devcontainer.json`?

The intent of `devcontainer.json` is similar to `launch.json` for debugging, but designed to launch (or attach to) a development container instead. At its simplest, all you need to do is add a `.devcontainer/devcontainer.json` file to your project that references an image, `Dockerfile`, or `docker-compose.yml`, and a few properties. You can [adapt it for use](https://aka.ms/vscode-remote/containers/folder-setup) in a wide variety of situations.

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
