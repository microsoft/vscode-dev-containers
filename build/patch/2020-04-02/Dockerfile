#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/python:0.109.0-3.7
FROM ${ORIGINAL_IMAGE}

RUN apt-get update \
    && apt-get purge -y imagemagick imagemagick-6-common \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
