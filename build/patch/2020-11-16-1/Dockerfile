#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/cpp@sha256:2379aebcd72d4f991ce49b7158529e51081f0cd082a4eaba19d14411e9f51369
FROM ${ORIGINAL_IMAGE}


RUN apt-get update \
    && apt-get upgrade -y util-linux gnupg2 libgnutls[0-9][0-9] \
    && if dpkg -s libssl1.0.0 2>/dev/null; then \
        apt-get upgrade -y libssl1.0.0; \
    fi \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
