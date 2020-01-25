#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=devcon.azurecr.io/public/vscode/devcontainers/base:0.99-ubuntu-18.04
FROM ${ORIGINAL_IMAGE}

RUN apt-get update && apt-get upgrade -y libgcrypt20
