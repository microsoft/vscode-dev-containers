#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM microsoft/dotnet:2.1-sdk-bionic

# Install git, process tools, bash
RUN apt-get update && apt-get -y install git procps

# Install Node.js via NVM - See https://github.com/creationix/nvm
# Change the "lts/*" in the two lines below to pick a different version
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash \
    && /bin/bash -c "source $HOME/.nvm/nvm.sh \
        && nvm install lts/* \
        && nvm alias default lts/*"

# Install eslint
RUN /bin/bash -c "source $HOME/.nvm/nvm.sh && npm install -g eslint"

# Install Azure Functions
RUN apt-get install -y apt-transport-https \
    && curl -sSO https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y azure-functions-core-tools
    
# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
