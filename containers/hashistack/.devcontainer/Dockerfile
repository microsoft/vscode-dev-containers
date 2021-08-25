#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
FROM ubuntu:18.04

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Docker Compose.
ARG COMPOSE_VERSION=1.24.0

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Verify git, zsh, vim, process tools installed
    && apt-get -y install git iproute2 procps zsh unzip neovim \
    #
    # Install Docker CE CLI
    && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    #
    # Install Docker Compose
    && curl -sSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Oh-My-ZSH
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN echo 'alias vim=nvim' >> ~/.zshrc

# Switch back to dialog for any ad-hoc use of apt-get
# TODO: Move this down once everything settles.
ENV DEBIAN_FRONTEND=dialog

# Hashicorp.
WORKDIR /ops

## Consul
ARG CONSUL_VERSION=1.6.1
ARG CONSULDOWNLOAD=https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
ARG CONSULCONFIGDIR=/etc/consul.d
ARG CONSULDIR=/opt/consul 

### Download
RUN curl -L $CONSULDOWNLOAD > consul.zip

### Install
RUN unzip consul.zip -d /usr/local/bin
RUN chmod 0755 /usr/local/bin/consul
RUN chown root:root /usr/local/bin/consul

### Configure
RUN mkdir -p $CONSULCONFIGDIR
RUN chmod 755 $CONSULCONFIGDIR
RUN mkdir -p $CONSULDIR
RUN chmod 755 $CONSULDIR

## Consul Template
ARG CONSUL_TEMPLATE_VERSION=0.20.0
ARG CONSULTEMPLATEDOWNLOAD=https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
ARG CONSULTEMPLATECONFIGDIR=/etc/consul-template.d
ARG CONSULTEMPLATEDIR=/opt/consul-template

### Download
RUN curl -L $CONSULTEMPLATEDOWNLOAD > consul-template.zip

## Install
RUN unzip consul-template.zip -d /usr/local/bin
RUN chmod 0755 /usr/local/bin/consul-template
RUN chown root:root /usr/local/bin/consul-template

## Configure
RUN mkdir -p $CONSULTEMPLATECONFIGDIR
RUN chmod 755 $CONSULTEMPLATECONFIGDIR
RUN mkdir -p $CONSULTEMPLATEDIR
RUN chmod 755 $CONSULTEMPLATEDIR

## Vault
ARG VAULT_VERSION=1.3.1
ARG VAULTDOWNLOAD=https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
ARG VAULTCONFIGDIR=/etc/vault.d
ARG VAULTDIR=/opt/vault

### Download
RUN curl -L $VAULTDOWNLOAD > vault.zip

### Install
RUN unzip vault.zip -d /usr/local/bin
RUN chmod 0755 /usr/local/bin/vault
RUN chown root:root /usr/local/bin/vault

### Configure
RUN mkdir -p $VAULTCONFIGDIR
RUN chmod 755 $VAULTCONFIGDIR
RUN mkdir -p $VAULTDIR
RUN chmod 755 $VAULTDIR

## Nomad
ARG NOMAD_VERSION=0.10.2
ARG NOMADDOWNLOAD=https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
ARG NOMADCONFIGDIR=/etc/nomad.d
ARG NOMADDIR=/opt/nomad

### Download
RUN curl -L $NOMADDOWNLOAD > nomad.zip

### Install
RUN unzip nomad.zip -d /usr/local/bin
RUN chmod 0755 /usr/local/bin/nomad
RUN chown root:root /usr/local/bin/nomad

### Configure
RUN mkdir -p $NOMADCONFIGDIR
RUN chmod 755 $NOMADCONFIGDIR
RUN mkdir -p $NOMADDIR
RUN chmod 755 $NOMADDIR
