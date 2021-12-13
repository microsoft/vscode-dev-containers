#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/dotnet.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./dotnet-debian.sh [dotnet version] [dotnet runtime only]

set -e

DOTNET_VERSION=${1:-"latest"}
DOTNET_RUNTIME_ONLY=${2:-"false"} # TODO: Ask Chuck about if runtime installation is a usecase we want to cover
MICROSOFT_GPG_KEYS_URI="https://packages.microsoft.com/keys/microsoft.asc"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Function to validate inputs

# Get central common setting
get_common_setting() {
    if [ "${common_settings_file_loaded}" != "true" ]; then
        curl -sfL "https://aka.ms/vscode-dev-containers/script-library/settings.env" 2>/dev/null -o /tmp/vsdc-settings.env || echo "Could not download settings file. Skipping."
        common_settings_file_loaded=true
    fi
    if [ -f "/tmp/vsdc-settings.env" ]; then
        local multi_line=""
        if [ "$2" = "true" ]; then multi_line="-z"; fi
        local result="$(grep ${multi_line} -oP "$1=\"?\K[^\"]+" /tmp/vsdc-settings.env | tr -d '\0')"
        if [ ! -z "${result}" ]; then declare -g $1="${result}"; fi
    fi
    echo "$1=${!1}"
}

# Function to run apt-get if needed
apt_get_update_if_needed() {
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

# validate inputs

echo "(*) Installing dotnet CLI..."
. /etc/os-release
architecture="$(dpkg --print-architecture)"

# Install dependencies
check_packages apt-transport-https curl ca-certificates gnupg2 dirmngr

# Import key safely and import Microsoft apt repo
get_common_setting MICROSOFT_GPG_KEYS_URI
curl -sSL ${MICROSOFT_GPG_KEYS_URI} | gpg --dearmor > /usr/share/keyrings/microsoft-archive-keyring.gpg
echo "deb [arch=${architecture} signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/microsoft-${ID}-${VERSION_CODENAME}-prod ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/microsoft.list
apt-get update

if [ "${DOTNET_VERSION}" = "latest" ] || [ "${DOTNET_VERSION}" = "lts" ]; then
    DOTNET_VERSION="6.0"
fi

if [ "${DOTNET_RUNTIME_ONLY}" = "true" ]; then
    DOTNET_SDK_OR_RUNTIME="runtime"
else
    DOTNET_SDK_OR_RUNTIME="sdk"
fi

if ! (apt-get install -yq dotnet-${DOTNET_SDK_OR_RUNTIME}-${DOTNET_VERSION}); then
    return 1
fi

echo "Done!"