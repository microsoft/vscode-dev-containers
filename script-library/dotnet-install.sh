#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs:
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./dotnet-install.sh

DOTNET_VERSION=${1:-"latest"}

curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version "${DOTNET_VERSION}"

echo "export PATH=/home/vscode/.dotnet:${PATH}" > ~/.bashrc