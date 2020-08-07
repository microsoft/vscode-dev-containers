# To fully customize the contents of this image, use the following Dockerfile as a base and add the RUN statement from this file:
# https://github.com/microsoft/vscode-dev-containers/blob/master/containers/debian/.devcontainer/base.Dockerfile
ARG VARIANT=buster
FROM mcr.microsoft.com/vscode/devcontainers/base:${VARIANT}

# Install needed packages. Use a separate RUN statement to add your own dependencies.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install build-essential cmake cppcheck valgrind \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
