# Development Container Scripts

This folder contains a set of scripts that can be referenced by Dockerfiles in development container "definitions" that are found under the [`containers` directory](../containers). When referenced properly, a hash is generated upon release that ensures that only the expected version of this script is executed. See [this Dockerfile](../container-templates/dockerfile/.devcontainer/Dockerfile) for an example.

Note that this folder contains a dev container that can be used to test the scripts before committing them to source control.

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details on contributing definitions to this repository.

## Scripts

- `common-debian.sh`, `common-alpine.sh`, `common-redhat.sh` - Installs common packages and utilities, creates a non-root user, and optionally upgrades packages, and installs zsh and Oh My Zsh!
- `docker-debian.sh` - Installs the Docker CLI and wires up a script thatt can enable non-root access to the Docker socket. See [Docker in Docker](../containers/docker-in-docker) for an example.

## Using a script

To use a script, simply download it using `curl` or `wget` and execute it. For example:

```Dockerfile
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive  \
    && apt-get -y install --no-install-recommends curl ca-certificates \
    && curl -sSL -o- "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/common-debian.sh" | bash -
```

Some scripts include arguments that you can allow developers to set by using `ARG` in your `Dockerfile`. In addition, you can cause the build system for this repository to generate and validate a `SHA` checksum to verify the script has not been changed by adding the script to an `ARG` that ends in `_SCRIPT_SOURCE` and `_SCRIPT_SHA`.

For example:

```Dockerfile
# Options for common package install script - SHA updated on release
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="true"
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="dev-mode"

# Configure apt and install packages
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends curl ca-certificates 2>&1 \
    && curl -sSL  ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
    && ([ "${COMMON_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} /tmp/common-setup.sh" | sha256sum -c -)) \
    && /bin/bash /tmp/common-setup.sh "${INSTALL_ZSH}" "vscode" "1000" "1000" "${UPGRADE_PACKAGES}" \
    && rm /tmp/common-setup.sh
```

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE)
