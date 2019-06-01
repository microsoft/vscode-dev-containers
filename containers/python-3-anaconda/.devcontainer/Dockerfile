#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM continuumio/anaconda3

# Install git, process tools
RUN apt-get update && apt-get -y install git procps

RUN mkdir /workspace
WORKDIR /workspace

# Install Python dependencies from requirements.txt if it exists
COPY .devcontainer/environment.yml.temp environment.yml* /workspace/
RUN if [ -f "environment.yml" ]; then conda env update base -f environment.yml && rm environment.yml*; fi

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Set the default shell to bash instead of sh
ENV SHELL /bin/bash

