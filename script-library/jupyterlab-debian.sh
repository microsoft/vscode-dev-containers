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

VERSION=${1:-"latest"}
USERNAME=${2:-"automatic"}
PYTHON=${3:-"python"}

# If in automatic mode, determine if a user already exists, if not use vscode
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in ${POSSIBLE_USERS[@]}; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=vscode
    fi
elif [ "${USERNAME}" = "none" ]; then
    USERNAME=root
    USER_UID=0
    USER_GID=0
fi

# Make sure we run the command as non-root user
sudoUserIf() {
  if [ "$(id -u)" -eq 0 ] && [ "${USERNAME}" != "root" ]; then
    sudo -u ${USERNAME} "$@"
  else
    "$@"
  fi
}

# Make sure that Python is available
if ! ${PYTHON} --version > /dev/null ; then
  echo "You need to install Python before installing JupyterLab."
  exit 1
fi

# pip skips installation if JupyterLab is already installed
echo "Installing JupyterLab..."
if [ "${VERSION}" = "latest" ]; then
  sudoUserIf ${PYTHON} -m pip install jupyterlab --no-cache-dir
else
  sudoUserIf ${PYTHON} -m pip install jupyterlab=="${VERSION}" --no-cache-dir
fi
