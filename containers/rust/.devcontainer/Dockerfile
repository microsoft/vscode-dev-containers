#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM rust:1

# Copy endpoint specific user setting overrides into container
COPY .devcontainer/settings.vscode.json /root/.vscode-remote/data/User/settings.json

RUN rustup update
RUN rustup component add rls rust-analysis rust-src

# Install git
RUN apt-get update && apt-get -y install git

# Install other dependencies
RUN apt-get install -y lldb-3.9

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
