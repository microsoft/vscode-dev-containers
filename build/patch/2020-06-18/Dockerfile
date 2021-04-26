#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/python@sha256:cc578248f55ebeac390808bc95a9df2d54b89108ca7fd933b82750d14800c93f
FROM ${ORIGINAL_IMAGE}

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get upgrade -y libgnutls-dane0 libgnutls-openssl27 libgnutls28-dev libgnutls30 libgnutlsxx28 \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
