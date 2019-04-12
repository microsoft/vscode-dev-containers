#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM microsoft/dotnet:2.1-sdk-bionic

# Install git, process tools
RUN apt-get update && apt-get -y install git procps

# Install Node.js
# Update "setup" to "setup_<verison>.x" if you want a specific verison of Node.js
# See https://github.com/nodesource/distributions/tree/master/deb for a list
RUN apt-get install -y curl \
    && curl -sSL https://deb.nodesource.com/setup | bash - \
    && apt-get update \
    && apt-get install -y nodejs 

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
