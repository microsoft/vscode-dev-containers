# Development Container Scripts

This folder contains a set of scripts that can be referenced by Dockerfiles in development container "definitions" that are found under the [`containers` directory](../containers). When referenced properly, a hash is generated upon release that ensures that only the expected version of this script is executed. See [this Dockerfile](../container-templates/dockerfile/.devcontainer/Dockerfile) for an example.

The `test` sub-folder includes Debian, Alpine, and RedHat based dev containers that can be used to test the scripts.

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details on contributing definitions to this repository.

## Scripts

- `common-debian.sh`, `common-alpine.sh`, `common-redhat.sh` - Installs common packages and utilities, creates a non-root user, and optionally upgrades packages, and installs zsh and Oh My Zsh!
- `docker-debian.sh` - Installs the Docker CLI and wires up a script that can enable non-root access to the Docker socket. See [Docker from Docker](../containers/docker-from-docker) for an example. Generally assumes `common-debian.sh` has been run.
- `node-debian.sh` - Installs the [Node Version Manager](https://github.com/nvm-sh/nvm) (nvm), the specified version of Node.js (if any) using nvm, ensures the specified non-root user can access everything. See [.NET Core](../containers/dotnet) for an example. Generally assumes `common-debian.sh` has been run.

## Using a script

To use a script, simply download it using `curl` or `wget` and execute it. For example:

```Dockerfile
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive  \
    && apt-get -y install --no-install-recommends curl ca-certificates \
    && curl -sSL -o- "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/common-debian.sh" | bash -
```

### Arguments

Some scripts include arguments that you can allow developers to set by using `ARG` in your `Dockerfile`.

```Dockerfile
# Options for script
ARG INSTALL_ZSH="true"

# Download script and run it with the option above
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive  \
    && apt-get -y install --no-install-recommends curl ca-certificates \
    && curl -sSL -o- "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.130.0/script-library/common-debian.sh" | bash -s -- "${INSTALL_ZSH}" "vscode" "1000" "1000" "true"
```

### Validating a file's checksum for security

In addition, you can cause the build system for this repository to generate and validate a `SHA` checksum to verify the script has not been changed by adding the script to an `ARG` that ends in `_SCRIPT_SOURCE` and `_SCRIPT_SHA`.

For example:

```Dockerfile
# Options for script
ARG INSTALL_ZSH="true"
ARG USERNAME="vscode"
ARG USER_UID="1000"
ARG USER_GID="${USER_UID}"
ARG UPGRADE_PACKAGES="true"

# Script source
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="dev-mode"

# Download script, validate its checksum, and run it with the options above
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends curl ca-certificates 2>&1 \
    && curl -sSL  ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
    && ([ "${COMMON_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/common-setup.sh" | sha256sum -c -)) \
    && /bin/bash /tmp/common-setup.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    && rm /tmp/common-setup.sh
```

When a release is created, the SHA will be automatically added to the tagged source code. e.g. in v1.30.0, these updates are applied:

```Dockerfile
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.130.0/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="a6bfacc5c9c6c3706adc8788bf70182729767955b7a5509598ac205ce6847e1e"
```

This locks the version of the script to v1.30.0 and will verify that the script has not been modified before running it.

Check out the [v1.30.0 tag for the Ubuntu definition](https://github.com/microsoft/vscode-dev-containers/blob/v0.130.0/containers/ubuntu/.devcontainer/base.Dockerfile) to see a real world example of the script doing this for you.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE)
