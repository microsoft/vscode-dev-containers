#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/universal@sha256:b4a11fddd10ad198b12ee36da29f3ca7e0f12963688943b2f471a704437af003
FROM ${ORIGINAL_IMAGE}

RUN sudo apt-get update  \
    && export DEBIAN_FRONTEND=noninteractive \
    && sudo apt-get upgrade -y git libcurl3-gnutls libpq-dev \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*
