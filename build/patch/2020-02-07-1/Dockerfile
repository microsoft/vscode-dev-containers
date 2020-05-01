#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Fix for USN-4256-1

ARG ORIGINAL_IMAGE=devcon.azurecr.io/public/vscode/devcontainers/base:0.45.1-ubuntu-18.04
FROM ${ORIGINAL_IMAGE}

RUN apt-get update  \
    && apt-get upgrade -y libsasl2-2 \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
