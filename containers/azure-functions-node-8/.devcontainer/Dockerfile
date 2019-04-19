#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM mcr.microsoft.com/dotnet/core/sdk:2.1

# Verify git and needed tools are installed
RUN apt-get update && apt-get -y install git curl tar procps

# Install Node.js via NVM -  See https://github.com/creationix/nvm
# Change the number "8" in the two lines below to pick a different version
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash \
    && /bin/bash -c "source $HOME/.nvm/nvm.sh \
        && nvm install 8 \
        && nvm alias default 8"

# Install eslint
RUN /bin/bash -c "source $HOME/.nvm/nvm.sh && npm install -g eslint"

# Install latest yarn
RUN curl -sfSLO --compressed "https://yarnpkg.com/latest.tar.gz" \
    && rm -rf /opt/yarn-* \
    && tar -xzf latest.tar.gz -C /opt/ \
    && ln -snf /opt/yarn-v*/bin/yarn /usr/local/bin/yarn \
    && ln -snf /opt/yarn-v*/bin/yarnpkg /usr/local/bin/yarnpkg \
    && rm latest.tar.gz

# Install Azure Functions and Azure CLI
RUN apt-get install -y apt-transport-https curl gnupg2 lsb-release \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list \
    && curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y azure-cli azure-functions-core-tools
    
# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
