#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM python:3

# Copy default endpoint specific user settings overrides into container to specify Python path
COPY .devcontainer/settings.vscode.json /root/.vscode-remote/data/Machine/settings.json

# Install git, process tools
RUN apt-get update && apt-get -y install git procps

RUN mkdir /workspace
WORKDIR /workspace

# Install pylint
RUN pip install pylint

# Install Python dependencies from requirements.txt if it exists
COPY .devcontainer/requirements.txt.temp requirements.txt* /workspace/
RUN if [ -f "requirements.txt" ]; then pip install -r requirements.txt && rm requirements.txt*; fi

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

