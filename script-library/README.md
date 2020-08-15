# Development Container Scripts

This folder contains a set of scripts that can be referenced by Dockerfiles in development container "definitions" that are found under the [`containers` directory](../containers). You are also free to use them in your own dev container configurations.

The `test` sub-folder includes Debian, Alpine, and RedHat based dev containers that can be used to test the scripts.

## Scripts

Script names end in the Linux distribution "tree" they support.

- `-debian` - Debian or Ubuntu
- `-redhat` - CentOS, RHEL, Oracle Linux
- `-alpine` - Alpine Linux

| Script | Arguments | Purpose |
|--------|---------|-----------|
| `common-debian.sh`<br />`common-alpine.sh`<br />`common-redhat.sh` | `[INSTALL ZSH FLAG] [USERNAME] [USER UID] [USER GID] [UPGRADE PACKAGES FLAG]`<br /><br /> Defaults to `true vscode 1000 1000 true`. Set `USERNAME` to `none` to skip setting up a non-root user. | Installs common packages and utilities, creates a non-root user, and optionally upgrades packages, and installs zsh and Oh My Zsh! |
| `docker-debian.sh`<br />`docker-redhat.sh` | `[ENABLE NON-ROOT ACCESS] [SOURCE SOCKET] [TARGET SOCKET] [USERNAME]`<br /><br /> Defaults to `true /var/run/docker-host.sock /var/run/docker.sock vscode`. Only sets up `USERNAME` if the user exists on the system.| Installs the Docker CLI and wires up a script that can enable non-root access to the Docker socket. See the [docker-from-docker](../containers/docker-from-docker) definition for an example. |
| `maven-debian.sh` | `<MAVEN VERSION> [MAVEN INSTALL DIRECTORY] [USERNAME] [DOWNLOAD SHA512]`<br /><br />`MAVEN VERSION` is required. Other arguments default to `/usr/local/share/maven vscode dev-mode`. Only sets up `USERNAME` if the user exists on the system. Download checksum is skipped if set to `dev-mode`. | Installs [Apache Maven](https://github.com/nvm-sh/nvm) and ensures the specified non-root user can access everything. See the [java](../containers/java) definition for an example. |
| `gradle-debian.sh` | `<GRADLE VERSION> [GRADLE INSTALL DIRECTORY] [USERNAME] [DOWNLOAD SHA256]`<br /><br />`GRADLE VERSION` is required. Other arguments default to `/usr/local/share/gradle vscode no-check`. Only sets up `USERNAME` if the user exists on the system. Download checksum is skipped if set to `no-check`. | Installs the [Gradle](https://github.com/nvm-sh/nvm) and ensures the specified non-root user can access everything. See the [java](../containers/java) definition for an example. |
| `node-debian.sh` | `[NVM INSTALL DIRECTORY] [NODE VERSION TO INSTALL] [USERNAME]`<br /><br />Defaults to `/usr/local/share/nvm lts/* vscode`. Only sets up `USERNAME` if the user exists on the system. | Installs the [Node Version Manager](https://github.com/nvm-sh/nvm) (nvm), the specified version of Node.js (if any) using nvm, ensures the specified non-root user can access everything. See the [dotnetcore](../containers/dotnetcore) definition for an example. |
| `terraform-debian.sh` | `<TERRAFORM VERSION> [TFLINT VERSION]`<br /><br />Only installs [tflint](https://github.com/terraform-linters/tflint) if `[TFLINT VESION]` is specified. | Installs the specified version of [Terraform](https://www.terraform.io/) in the container. Can be combined with `docker-debian.sh` to enable local testing via Docker. See the [azure-terraform](../azure-terraform) definition for an example. |

## Using a script

### Copying the script to .devcontainer/library-scripts

The easiest way to use a script is to simply copy it into a `.devcontainers/library-scripts` folder. From here you can then use the script as follows in your `Dockerfile`:

**Debian/Ubuntu**

```Dockerfile
COPY library-scripts/*.sh /tmp/library-scripts/
RUN /tmp/library-scripts/common-debian.sh
```

Generally it's also good to clean up after running a script in the same `RUN` statement to keep the "layer" small.

```Dockerfile
COPY library-scripts/*.sh /tmp/library-scripts/
RUN /tmp/library-scripts/common-debian.sh
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts
```

**Alpine**

```Dockerfile
COPY library-scripts/*.sh /tmp/library-scripts/
RUN /bin/ash /tmp/library-scripts/common-alpine.sh \
    && rm -rf /tmp/library-scripts
```

**CentOS/RedHat/Oracle Linux**

```Dockerfile
COPY library-scripts/*.sh /tmp/library-scripts/
RUN /bin/bash /tmp/library-scripts/common-redhat.sh \
    && yum clean all && rm -rf /tmp/library-scripts
```

Note that the CI process for this repository will automatically keep scripts in the `.devcontainers/library-scripts` folder up to date for each definition in the `containers` folder.

### Downloading the script with curl instead

If you prefer, you can download the script using `curl` or `wget` and execute it instead. This can convenient to do with your own `Dockerfile`, but is generally avoided for definitions in this repository. To avoid unexpected issues, you should reference a release specific version of the script, rather than using master. For example:

```Dockerfile
RUN curl -sSL -o- "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.131.0/script-library/common-debian.sh" | bash -
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
```

Or if you're not sure if `curl` is installed:

```Dockerfile
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive  \
    && apt-get -y install --no-install-recommends curl ca-certificates \
    && curl -sSL -o- "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.131.0/script-library/common-debian.sh" | bash - \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
```

As before, the last line is technically optional, but minimizes the size of the layer by removing temporary contents.  

### Arguments

Some scripts include arguments that you can allow developers to set by using `ARG` in your `Dockerfile`.

#### Using arguments with scripts from the .devcontainers/library-scripts folder

In this case, you can simply pass in the arguments to the script.

```Dockerfile
# Options for script
ARG INSTALL_ZSH="true"

COPY library-scripts/*.sh /tmp/library-scripts/
RUN /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "vscode" "1000" "1000" "true" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts
```

#### Using arguments when downloading with curl

The trick here is to use the syntax `| bash -s --` after the `curl` command and then listing the arguments.

```Dockerfile
# Options for script
ARG INSTALL_ZSH="true"

# Download script and run it with the option above
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive  \
    && apt-get -y install --no-install-recommends curl ca-certificates \
    && curl -sSL -o- "hhttps://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.131.0/script-library/common-debian.sh" | bash -s -- "${INSTALL_ZSH}" "vscode" "1000" "1000" "true" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details on contributing definitions to this repository.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE)
