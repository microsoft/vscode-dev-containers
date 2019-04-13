#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

# Pick any base image, but if you select node, skip installing node. 😊
FROM debian:9

# Install git, required tools
RUN apt-get update \
	&& apt-get install -y \
            git \
            curl \
            procps \
            unzip \
            apt-transport-https \
            ca-certificates \
            gnupg-agent \
            software-properties-common

# [Optional] Install Node.js for Azure Cloud Shell support 
# Change the "lts/*" in the two lines below to pick a different version
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash \
    && /bin/bash -c "source $HOME/.nvm/nvm.sh \
        && nvm install lts/* \
        && nvm alias default lts/*"

# [Optional] For local testing instead of cloud shell
# Install Docker CE CLI. 
RUN && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli

# [Optional] For local testing instead of cloud shell
# Install the Azure CLI
RUN  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list \
    && curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y azure-cli 

# Install Terraform and tflint
RUN mkdir -p /tmp/docker-downloads \
    && curl -sSL -o /tmp/docker-downloads/terraform.zip https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip \
    && unzip /tmp/docker-downloads/terraform.zip \
    && mv terraform /usr/local/bin \
    && curl -sSL -o /tmp/docker-downloads/tflint.zip https://github.com/wata727/tflint/releases/download/v0.7.5/tflint_linux_amd64.zip \
    && unzip /tmp/docker-downloads/tflint.zip \
    && mv tflint /usr/local/bin \
    && cd ~ \ 
    && rm -rf /tmp/docker-downloads \
    && apt-get install -y graphviz

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*