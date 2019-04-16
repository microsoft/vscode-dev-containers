#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM continuumio/anaconda3

# Copy default endpoint specific user settings overrides into container to specify Python path
COPY .devcontainer/settings.vscode.json /root/.vscode-remote/data/Machine/settings.json

# Install git, process tools
RUN apt-get update && apt-get -y install git procps

# Install any missing dependencies for enhanced language service
RUN apt-get install -y libicu[0-9][0-9]

RUN mkdir /workspace
WORKDIR /workspace

# Install Python dependencies from requirements.txt if it exists
COPY .devcontainer/environment.yml.temp environment.yml* /workspace/
RUN if [ -f "environment.yml" ]; then conda env update base -f environment.yml && rm environment.yml*; fi

# Expose port 5000 as the default web port
EXPOSE 5000

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

