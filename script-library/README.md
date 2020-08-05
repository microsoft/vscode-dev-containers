# Development Container Scripts

This folder contains a set of scripts that can be referenced by Dockerfiles in development container "definitions" that are found under the [`containers` directory](../containers). When referenced properly, a hash is generated upon release that ensures that only the expected version of this script is executed. See [this Dockerfile](../container-templates/dockerfile/.devcontainer/Dockerfile) for an example.

The `test` sub-folder includes Debian, Alpine, and RedHat based dev containers that can be used to test the scripts.

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details on contributing definitions to this repository.

## Scripts

- `common-debian.sh`, `common-alpine.sh`, `common-redhat.sh` - Installs common packages and utilities, creates a non-root user, and optionally upgrades packages, and installs zsh and Oh My Zsh!
- `docker-debian.sh`, `docker-redhat.sh` - Installs the Docker CLI and wires up a script that can enable non-root access to the Docker socket. See [Docker from Docker](../containers/docker-from-docker) for an example. Generally assumes `common-debian.sh` has been run.
- `node-debian.sh` - Installs the [Node Version Manager](https://github.com/nvm-sh/nvm) (nvm), the specified version of Node.js (if any) using nvm, ensures the specified non-root user can access everything. See [.NET Core](../containers/dotnet) for an example. Generally assumes `common-debian.sh` has been run.

## Using a script


### Copying the script to .devcontainer/library-scripts

The easiest way to use a script is to simply copy it into a `.devcontainers/library-scripts` folder. From here you can then use the script as follows in your `Dockerfile`:

**Debian/Ubuntu**

```Dockerfile
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts
```

**Alpine**

```Dockerfile
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apk update \
    && /bin/ash /tmp/library-scripts/common-alpine.sh \
    && rm -rf /tmp/library-scripts
```

**CentOS/RedHat/Oracle Linux**

```Dockerfile
COPY library-scripts/*.sh /tmp/library-scripts/
RUN /bin/bash /tmp/library-scripts/common-redhat.sh \
    && yum clean all && rm -rf /tmp/library-scripts
```

The last line is technically optional, but minimizes the size of the layer by removing temporary contents.  

The CI process for this repository will automatically keep scripts in the `.devcontainers/library-scripts` folder up to date for each definition in the `containers` folder.

### Downloading the script with curl instead

If you prefer, you can download the script using `curl` or `wget` and execute it instead. This can convienent to do with your own `Dockerfile`, but is generally avoided for definitions in this repository. To avoid unexpected issues, you should reference a release specific version of the script, rather than using master. For example:

```Dockerfile
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive  \
    && apt-get -y install --no-install-recommends curl ca-certificates \
    && curl -sSL -o- "https://github.com/microsoft/vscode-dev-containers/blob/v0.131.0/script-library/common-debian.sh" | bash - \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
```

The last line is technically optional, but minimizes the size of the layer by removing temporary contents.  

### Arguments

Some scripts include arguments that you can allow developers to set by using `ARG` in your `Dockerfile`.

#### Using arguments with scripts from the .devcontainers/library-scripts folder

In this case, you can simply pass in the arguments to the script.

```Dockerfile
# Options for script
ARG INSTALL_ZSH="true"

COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "vscode" "1000" "1000" "true" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts
```

#### Using arguments when downloading with curl

The trick here is to use the syntax `| bash -s --` after the `curl` command and then listing the arguments.

```Dockerfile
# Options for script
ARG INSTALL_ZSH="true"

# Download script and run it with the option above
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive  \
    && apt-get -y install --no-install-recommends curl ca-certificates \
    && curl -sSL -o- "https://github.com/microsoft/vscode-dev-containers/blob/v0.131.0/script-library/common-debian.sh" | bash -s -- "${INSTALL_ZSH}" "vscode" "1000" "1000" "true" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
```

### [Optional] Validating a file's checksum for security when using curl

If for some reason you cannot copy the script you want to use into the `.devcontainer/library-scripts` folder, you can improve security using a checksum. The CI process will automatically generate a checksum on release if you add two related `ARG`s that end in `_SCRIPT_SOURCE` and `_SCRIPT_SHA`.

For example:

```Dockerfile
# Options for script
ARG INSTALL_ZSH="true"

# Script source
ARG COMMON_SCRIPT_SOURCE="https://github.com/microsoft/vscode-dev-containers/blob/v0.131.0/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="dev-mode"

# Download script, validate its checksum, and run it with the options above
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends curl ca-certificates 2>&1 \
    && curl -sSL  ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
    && ([ "${COMMON_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/common-setup.sh" | sha256sum -c -)) \
    && /bin/bash /tmp/common-setup.sh "${INSTALL_ZSH}" "vscode" "1000" "1000" "true" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/common-setup.sh
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
