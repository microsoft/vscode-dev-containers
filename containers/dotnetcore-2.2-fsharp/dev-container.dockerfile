#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM microsoft/dotnet:2.2-sdk

# Alias xterm to bash if external console is triggered
RUN echo "alias xterm=bash" >> /root/.bashrc

# Install git
RUN apt-get update && apt-get -y install git

# Install fsharp
RUN apt-get install -y fsharp

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
	
