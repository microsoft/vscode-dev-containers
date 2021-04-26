#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/universal@sha256:36418523e2c261a47d081990475fe63fed88b5e8693b73c4f550b1025e30b89e
FROM ${ORIGINAL_IMAGE}

RUN sudo apt-get update  \
    && export DEBIAN_FRONTEND=noninteractive \
    # Always upgrade git
    && sudo apt-get upgrade -y git \
    # See if libssl-dev installed, upgrade if so
    && if dpkg -s libssl-dev 2>/dev/null; then \
        sudo apt-get upgrade -y libssl-dev libssl1.1; \
    fi \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

