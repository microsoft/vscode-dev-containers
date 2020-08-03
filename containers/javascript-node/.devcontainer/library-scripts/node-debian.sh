#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Syntax: ./node-debian.sh <directory to install nvm> <node version to install (use "none" to skip)> <non-root user>

set -e

export NVM_DIR=${1:-"/usr/local/share/nvm"}
export NODE_VERSION=${2:-"lts/*"}
NONROOT_USER=${3:-"vscode"}

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run a root. Use sudo or set "USER root" before running the script.'
    exit 1
fi

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

if [ "${NODE_VERSION}" = "none" ]; then
    export NODE_VERSION=
fi

# Install NVM
mkdir -p ${NVM_DIR}
curl -so- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash 2>&1
if [ "${NODE_VERSION}" != "" ]; then
    /bin/bash -c "source $NVM_DIR/nvm.sh && nvm alias default ${NODE_VERSION}" 2>&1
fi

echo -e "export NVM_DIR=\"${NVM_DIR}\"\n\
[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"\n\
[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\"" \
| tee -a /home/${NONROOT_USER}/.bashrc /home/${NONROOT_USER}/.zshrc >> /root/.zshrc

echo -e "if [ \"\$(stat -c '%U' \$NVM_DIR)\" != \"${NONROOT_USER}\" ]; then\n\
    sudo chown -R ${NONROOT_USER}:root \$NVM_DIR\n\
fi" | tee -a /root/.bashrc /root/.zshrc /home/${NONROOT_USER}/.bashrc >> /home/${NONROOT_USER}/.zshrc

chown ${NONROOT_USER}:${NONROOT_USER} /home/${NONROOT_USER}/.bashrc /home/${NONROOT_USER}/.zshrc
chown -R ${NONROOT_USER}:root ${NVM_DIR}

# Install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - 2>/dev/null
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt-get update
apt-get -y install --no-install-recommends yarn
