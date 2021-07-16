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

GIT_LFS_ARCHIVE_GPG_KEY_URI="https://packagecloud.io/github/git-lfs/gpgkey"

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

function getCommonSetting() {
    if [ "${COMMON_SETTINGS_LOADED}" != "true" ]; then
        curl -sL --fail-with-body "https://aka.ms/vscode-dev-containers/script-library/settings.env" 2>/dev/null -o /tmp/vsdc-settings.env || echo "Could not download settings file. Skipping."
        COMMON_SETTINGS_LOADED=true
    fi
    local multi_line=""
    if [ "$2" = "true" ]; then multi_line="-z"; fi
    if [ -f "/tmp/vsdc-settings.env" ]; then
        if [ ! -z "$1" ]; then declare -g $1="$(grep ${multi_line} -oP "${$1}=\"?\K[^\"]+" /tmp/vsdc-settings.env | tr -d '\0')"; fi
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Install git, curl, gpg, and debian-archive-keyring if missing
. /etc/os-release
if ! dpkg -s curl ca-certificates gnupg2 apt-transport-https > /dev/null 2>&1; then
    apt-get-update-if-needed
    apt-get -y install --no-install-recommends curl ca-certificates gnupg2 apt-transport-https
fi
if ! type git > /dev/null 2>&1; then
    apt-get-update-if-needed
    apt-get -y install --no-install-recommends git
fi
if [ "${ID}" = "debian" ] &&! dpkg -s debian-archive-keyring > /dev/null 2>&1; then
    apt-get-update-if-needed
    apt-get -y debian-archive-keyring
fi

# Install Git LFS
echo "Installing Git LFS..."
getCommonSetting GIT_LFS_ARCHIVE_GPG_KEY_URI
curl -sSL "${GIT_LFS_ARCHIVE_GPG_KEY_URI}" | gpg --dearmor > /usr/share/keyrings/gitlfs-archive-keyring.gpg
echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gitlfs-archive-keyring.gpg] https://packagecloud.io/github/git-lfs/${ID} ${VERSION_CODENAME} main\ndeb-src [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gitlfs-archive-keyring.gpg] https://packagecloud.io/github/git-lfs/${ID} ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/git-lfs.list
apt-get install -yq git-lfs
git lfs install
echo "Done!"