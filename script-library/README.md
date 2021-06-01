# Development Container Scripts

This folder contains a set of scripts that can be referenced by Dockerfiles in development container "definitions" that are found under the [`containers` directory](../containers). You are also free to use them in your own dev container configurations.

## Scripts

Script names end in the Linux distribution "tree" they support. The majority are for Ubuntu/Debian.

- **Debian or Ubuntu**: `-debian`
- **Alpine Linux**: `-alpine`
- **CentOS, RHEL**: `-redhat` (when the `yum` package manager is available - usually community supported).

Some scripts have special installation instructions (like `desktop-lite-debian.sh`). Consult the following documents for more information (in order of the script name):

| Document | Script | Maintainers |
|----------|--------|------------|
| [Azure CLI Install Script](docs/azcli.md) | `azcli-debian.sh` | VS Code and GitHub Codespaces teams |
| [Common Script](docs/common.md) | `common-debian.sh`<br />`common-alpine.sh`<br />`common-redhat.sh` (Community) | VS Code and GitHub Codespaces teams |
| [Desktop (Lightweight) Install Script](docs/desktop-lite.md) | `desktop-lite-debian.sh` | VS Code and GitHub Codespaces teams|
| [Docker-in-Docker Install Script](docs/docker-in-docker.md) | `docker-in-docker-debian.sh` | VS Code and GitHub Codespaces teams |
| [Docker-from-Docker Install Script](docs/docker.md) | `docker-debian.sh`<br />`docker-redhat.sh` (Community) | VS Code and GitHub Codespaces teams, [@smankoo](https://github.com/smankoo) (`docker-redhat.sh`) |
| [fish Install Script](docs/fish.md) | `fish-debian.sh` (Community) | [@andreiborisov](https://github.com/andreiborisov) |
| [Git Build/Install from Source Script](docs/git-from-src.md) | `git-from-src-debian.sh` | VS Code and GitHub Codespaces teams|
| [Git LFS Install Script](docs/git-lfs.md) | `git-lfs-debian.sh` | VS Code and GitHub Codespaces teams|
| [GitHub CLI Install Script](docs/github.md) | `github-debian.sh` | VS Code and GitHub Codespaces teams|
| [Go (golang) Install Script](docs/go.md) | `go-debian.sh` | VS Code and GitHub Codespaces teams|
| [Gradle Install Script](docs/gradle.md) | `gradle-debian.sh` | VS Code and GitHub Codespaces teams|
| [Homebrew Install Script](docs/homebrew.md) | `homebrew-debian.sh` (Community) | [@andreiborisov](https://github.com/andreiborisov) |
| [Java Install Script](docs/java.md) | `java-debian.sh` | VS Code and GitHub Codespaces teams|
| [Kubectl and Helm Install Script](docs/kubectl-helm.md) | `kubectl-helm-debian.sh` | VS Code and GitHub Codespaces teams|
| [Maven Install Script](docs/maven.md) | `maven-debian.sh` | VS Code and GitHub Codespaces teams|
| [Node.js Install Script](docs/node.md) | `node-debian.sh` | VS Code and GitHub Codespaces teams|
| [PowerShell Install Script](docs/powershell.md) | `powershell-debian.sh` | VS Code and GitHub Codespaces teams|
| [Python Install Script](docs/python.md) | `python-debian.sh` | VS Code and GitHub Codespaces teams|
| [Ruby Install Script](docs/ruby.md) | `ruby-debian.sh` | VS Code and GitHub Codespaces teams|
| [Rust (rustlang) Install Script](docs/rust.md) | `rust-debian.sh` | VS Code and GitHub Codespaces teams|
| [SSH Server Install Script](docs/sshd.md) | `sshd-debian.sh` | VS Code and GitHub Codespaces teams|
| [Terraform CLI Install Script](docs/terraform.md) | `terraform-debian.sh` | VS Code and GitHub Codespaces teams|

## Using a script

*See the [documentation above](#scripts) for specific instructions on individual scripts. This section will outline some general tips for alternate ways to reference the scripts in your Dockerfile.*

### Copying the script to .devcontainer/library-scripts

The easiest way to use a script is to simply copy it into a `.devcontainers/library-scripts` folder. From here you can then use the script as follows in your `Dockerfile`:

**Debian/Ubuntu**

```Dockerfile
COPY library-scripts/*.sh /tmp/library-scripts/
RUN bash /tmp/library-scripts/common-debian.sh
```

Generally it's also good to clean up after running a script in the same `RUN` statement to keep the "layer" small.

```Dockerfile
COPY library-scripts/*.sh /tmp/library-scripts/
RUN bash /tmp/library-scripts/common-debian.sh
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts
```

**Alpine**

```Dockerfile
COPY library-scripts/*.sh /tmp/library-scripts/
RUN ash /tmp/library-scripts/common-alpine.sh \
    && rm -rf /tmp/library-scripts
```

**CentOS/RedHat/Oracle Linux**

```Dockerfile
COPY library-scripts/*.sh /tmp/library-scripts/
RUN bash /tmp/library-scripts/common-redhat.sh \
    && yum clean all && rm -rf /tmp/library-scripts
```

Note that the CI process for this repository will automatically keep scripts in the `.devcontainers/library-scripts` folder up to date for each definition in the `containers` folder.

### Downloading the script with curl / wget instead

If you prefer, you can download the script using `curl` or `wget` and execute it instead. This can convenient to do with your own `Dockerfile`, but is generally avoided for definitions in this repository. To avoid unexpected issues, you should reference a release specific version of the script, rather than using main. For example:

```Dockerfile
RUN bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh")" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
```

Or if you're not sure if `curl` is installed:

```Dockerfile
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive  \
    && apt-get -y install --no-install-recommends curl ca-certificates \
    && bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh")" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
```

As before, the last line is technically optional, but minimizes the size of the layer by removing temporary contents.  

You can also use `wget`:

```Dockerfile
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive  \
    && apt-get -y install --no-install-recommends wget ca-certificates \
    && bash -c "$(wget -qO- "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh")" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
```

### Arguments

Some scripts include arguments that you can allow developers to set by using `ARG` in your `Dockerfile`.

#### Using arguments with scripts from the .devcontainers/library-scripts folder

In this case, you can simply pass in the arguments to the script.

```Dockerfile
# Options for script
ARG INSTALL_ZSH="true"

COPY library-scripts/*.sh /tmp/library-scripts/
RUN /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "vscode" "1000" "1000" "true" "true" "true"\
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts
```

#### Using arguments when downloading with curl

The trick here is to use the double-dashes (`--`) after the `bash -c` command and then listing the arguments.

```Dockerfile
# Options for script
ARG INSTALL_ZSH="true"

# Download script and run it with the option above
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive  \
    && apt-get -y install --no-install-recommends curl ca-certificates \
    && bash -c "$(curl -fsSL "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh")" -- "${INSTALL_ZSH}" "vscode" "1000" "1000" "true" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
```

## Testing

The `test/regression` sub-folder includes Debian, Alpine, and RedHat based dev containers that can be used to test the scripts.

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details on contributing definitions to this repository.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE)

