# Repository Development Containers

While we encourage you to add development container configuration files to your repositories so others can benefit from them, some organizations prefer to not include development tool related files in source control. To provide additional flexibility, this folder includes dev container definitions that will be be used if you open the cloned repository using [Remote - Containers](https://aka.ms/vscode-remote/download/containers) extension (if there is no `.devcontainer.json` or `.devcontainer/devcontainer.json` file locally). The `images` folder here is used to pre-build images that are then referenced here or directly in source code repositories.

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details on contributing a container.

If you are looking for a list of additional dev container definitions that are included in the [Remote - Containers](https://aka.ms/vscode-remote/download/containers) extension, see the [containers](../containers) folder instead.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE)
