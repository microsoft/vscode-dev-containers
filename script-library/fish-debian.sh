#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# ** This script is community supported **
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/fish.md
# Maintainer: @andreiborisov
#
# Syntax: ./fish-debian.sh [whether to install Fisher] [non-root user]

INSTALL_FISHER=${1:-"true"}
USERNAME=${2:-"automatic"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Determine the appropriate non-root user
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
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

export DEBIAN_FRONTEND=noninteractive

# Install fish shell
echo "Installing fish shell..."
if grep -q 'Ubuntu' < /etc/os-release; then
    apt-get -y install --no-install-recommends software-properties-common
    apt-add-repository ppa:fish-shell/release-3
    apt-get update
    apt-get -y install --no-install-recommends fish
    apt-get autoremove -y
elif grep -q 'Debian' < /etc/os-release; then
    if grep -q 'stretch' < /etc/os-release; then
        echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_9.0/ /' | tee /etc/apt/sources.list.d/shells:fish:release:3.list
        curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_9.0/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null
    elif grep -q 'buster' < /etc/os-release; then
        echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_10/ /' | tee /etc/apt/sources.list.d/shells:fish:release:3.list
        curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_10/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null
    fi
    apt update
    apt install -y fish
    apt autoremove -y
fi

# Install Fisher
if [ "${INSTALL_FISHER}" = "true" ]; then
    echo "Installing Fisher..."
    fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
    if [ "${USERNAME}" != "root" ]; then
        sudo -u $USERNAME fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
    fi
fi

echo "Done!"
