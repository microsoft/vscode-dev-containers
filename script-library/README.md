# Development Container Scripts

This folder contains a set of scripts that can be referenced by Dockerfiles in development container "definitions" that are found under the [`containers` directory](../containers). When referenced properly, a hash is generated upon release that ensures that only the expected version of this script is executed. See [this Dockerfile](../container-templates/dockerfile/.devcontainer/Dockerfile) for an example.

Note that this folder contains a dev container that can be used to test the scripts before committing them to source control.

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details on contributing definitions to this repository.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE)
