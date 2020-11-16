#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/universal@sha256:153ee106e49a108bef834078cb8e682cd82977d3095570c16bceed82f73d03a2
FROM ${ORIGINAL_IMAGE}

RUN sudo apt-get update \
    && sudo apt-get upgrade -y libxml2 \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*
