#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM node:lts

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

# Install git, process tools
RUN apt-get -y install git procps

# Install Truffle Suite
RUN npm i --unsafe-perm -g truffle

# Install Ganache CLI
RUN npm install -g ganache-cli

# Install the Azure CLI
RUN apt-get install -y apt-transport-https curl gnupg2 lsb-release \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - 2>/dev/null \
    && apt-get update \
    && apt-get install -y azure-cli
	
# Install Python 2.7.15
RUN apt-get install -y build-essential \
	&& curl https://www.python.org/ftp/python/2.7.15/Python-2.7.15.tgz --output Python-2.7.15.tgz \
	&& tar -xvf Python-2.7.15.tgz \
	&& rm Python-2.7.15.tgz \
	&& cd Python-2.7.15 \
	&& ./configure --enable-optimizations \
	&& make install

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

# Set the default shell to bash instead of sh
ENV SHELL /bin/bash
