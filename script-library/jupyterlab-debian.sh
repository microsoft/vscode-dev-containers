#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/jupyterlab.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./jupyter-debian.sh

set -e

JUPYTER_LAB_VERSION=${1:-"latest"}

# Install JupyterLab
echo "Installing JupyterLab..."
if [ "${JUPYTER_LAB_VERSION}" = "latest" ]; then
  pip install jupyterlab
else
  pip install jupyterlab=="${JUPYTER_LAB_VERSION}"
fi
