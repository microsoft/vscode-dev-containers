#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM node:lts

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# The node image comes with a base non-root 'node' user, so the alternate
# user here is primarily for Linux scenarios where you need to match your local
# user UID/GID. See https://aka.ms/vscode-remote/containers/non-root-user.
ARG USERNAME=vscode
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Verify git and needed tools are installed
    && apt-get -y install \
        git \
        procps \
        curl \
        apt-transport-https \
        gnupg2 \
        lsb-release \
    #
    # Install Azure Functions, .NET Core, and Azure CLI
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && apt-get update \
    && apt-get install -y azure-cli dotnet-sdk-2.1 azure-functions-core-tools \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && if [ "$USER_GID" != "1000" ]; then groupadd --gid $USER_GID $USERNAME; fi \
    && if [ "$USER_UID" != "1000" ]; then useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME; fi \
    # [Optional] Uncomment the next four lines to add sudo support
    # && apt-get install -y sudo \
    # && if [ "$USER_UID" != "1000" ]; then echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME; fi \
    # && echo node ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/node \
    # && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Install eslint
    && npm install -g eslint \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
        
# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=