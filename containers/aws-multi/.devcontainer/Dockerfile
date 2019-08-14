#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/core/sdk:2.2-bionic
#FROM buildpack-deps:bionic-scm

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Suppress an apt-key warning about standard out not being a terminal. Use in this script is safe.
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# Terraform and tflint versions
ARG TERRAFORM_VERSION=0.12.6
ARG TFLINT_VERSION=0.9.3

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1 \
# Verify git, process tools, lsb-release (common in install instructions for CLIs), iproute2 (for ip) installed
    && apt-get -y install git procps curl wget unzip lsb-release iproute2 dialog \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
#
# Install Python3
RUN apt-get update && apt-get -y install python3 python3-pip \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
#
# Install Terraform, tflint, and graphviz
RUN mkdir -p /tmp/docker-downloads \
    && curl -sSL -o /tmp/docker-downloads/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip /tmp/docker-downloads/terraform.zip \
    && mv terraform /usr/local/bin \
    && curl -sSL -o /tmp/docker-downloads/tflint.zip https://github.com/wata727/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && unzip /tmp/docker-downloads/tflint.zip \
    && mv tflint /usr/local/bin \
    && cd ~ \
    && rm -rf /tmp/docker-downloads \
    && apt-get update && apt-get -y install graphviz \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
#
# Install NodeJS and Yarn
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get -y install yarn \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
#
# Install Serverless Framework
RUN npm install -g serverless
#
# Install Postgres client
RUN apt-get update && apt-get -y install curl ca-certificates gnupg \
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && apt-get update \
    && apt-get -y install postgresql-client-11 \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
#
# Install kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubectl \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
#
# Install awscli
RUN apt-get update && apt-get -y install groff less python3-pip \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && pip3 install awscli \
    && rm -rf /var/lib/apt/lists/*
#
# Install aws-iam-authenticator
RUN curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator \
    && mv aws-iam-authenticator /usr/local/bin/ \
    && chmod 755 /usr/local/bin/aws-iam-authenticator
#
# Install dotnet tools
RUN dotnet new -i Amazon.Lambda.Templates::* \
    && dotnet tool install -g Amazon.Lambda.Tools \
    && apt-get update \
    && apt-get install -y zip \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
#
# Docker Compose version
ARG COMPOSE_VERSION=1.24.0
#
# Install Docker CE CLI
RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    #
    # Install Docker Compose
    && curl -sSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
#
# Or your actual UID, GID on Linux if not the default 1000
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
#
# Creata a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
#
# Setup a locale compatible with perl/brew
    && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.utf8
#
# Install Brew
USER vscode
WORKDIR /home/vscode
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
RUN echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
#
# Install AWS SAM CLI
RUN brew tap aws/tap && brew install aws-sam-cli

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
ENV AWS_SDK_LOAD_CONFIG=1
