#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/rust@sha256:5802d9ef8e3fb507233cdebf7928243e9597efca3ca174623cf7716eeb925405
FROM ${ORIGINAL_IMAGE}

RUN apt-get update \
    && apt-get upgrade -y libfreetype6 mariadb-common \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
