#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM rocker/r-apt:bionic

# Install git, process tools, lsb-release (common in install instructions for CLIs) and libzip for R Tools extension
RUN apt-get update && apt-get -y install git procps lsb-release libzip-dev

# Register Microsoft key and feed
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb

# Install the .NET Runtime
RUN add-apt-repository universe && \
    apt-get install apt-transport-https && \
    apt-get update && \
    apt-get -y install dotnet-runtime-2.1

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Set the default shell to bash instead of sh
ENV SHELL /bin/bash