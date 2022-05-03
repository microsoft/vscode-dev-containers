#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs:
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./python-ml-debian.sh

set -e

PYTHON=${1:-"python"}
ML_PACKAGES=${2:-"numpy pandas scipy matplotlib seaborn scikit-learn tensorflow keras torch requests"}

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

# Use sudo to run as non-root user is not already running
sudoUserIf()
{
  if [ "$(id -u)" -eq 0 ] && [ "${USERNAME}" != "root" ]; then
    sudo -u ${USERNAME} "$@"
  else
    "$@"
  fi
}

# Make sure that Python is installed correctly
if ! $PYTHON --version > /dev/null ; then
  echo "You need to install Python before installing ML packages."
  exit 1
fi

# pip skips installation when a requirement is already satisfied
sudoUserIf $PYTHON -m pip install $ML_PACKAGES
