#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/git-lfs.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./git-lfs-debian.sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Function to run apt-get if needed
apt-get-update-if-needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Install git, curl, gpg, and debian-archive-keyring if missing
. /etc/os-release
if ! dpkg -s git curl ca-certificates gnupg2 apt-transport-https > /dev/null 2>&1; then
    apt-get-update-if-needed
    apt-get -y install --no-install-recommends git curl ca-certificates gnupg2 apt-transport-https
fi
if [ "${ID}" = "debian" ] &&! dpkg -s debian-archive-keyring > /dev/null 2>&1; then
    apt-get-update-if-needed
    apt-get -y debian-archive-keyring
fi

# Install Git LFS
echo "Installing Git LFS..."
curl -sSL https://packagecloud.io/github/git-lfs/gpgkey | gpg --dearmor > /usr/share/keyrings/gitlfs-archive-keyring.gpg
echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gitlfs-archive-keyring.gpg] https://packagecloud.io/github/git-lfs/${ID} ${VERSION_CODENAME} main\ndeb-src [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gitlfs-archive-keyring.gpg] https://packagecloud.io/github/git-lfs/${ID} ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/git-lfs.list
apt-get install -yq git-lfs
git lfs install
echo "Done!"