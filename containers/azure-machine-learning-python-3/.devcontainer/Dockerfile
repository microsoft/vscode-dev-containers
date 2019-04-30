#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Update this to FROM python:3 if you'd prefer 
# to use standard python instead
FROM continuumio/anaconda3

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

# Copy default endpoint specific user settings overrides into container to 
# to specify Python path and that Docker should run as a workspace extension
COPY settings.vscode.json /root/.vscode-remote/data/Machine/settings.json

# Install git, required tools
RUN apt-get install -y \
            git \
            curl \
            procps \
            apt-transport-https \
            ca-certificates \
            gnupg-agent \
            software-properties-common \
            sudo \
            lsb-release 2>&1

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli

# Install pylint and Azure ML SDK
RUN pip install pylint azureml-sdk[notebooks,automl] 2>&1

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog
