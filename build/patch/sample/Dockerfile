#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=clantz.azurecr.io/vscode/devcontainers/python:dev-3
FROM ${ORIGINAL_IMAGE}

RUN apt-get update  \
    && apt-get upgrade -y libidn2-0 \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
