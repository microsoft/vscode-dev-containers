#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/git-from-src.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./git-from-src-debian.sh [version] [use PPA if available]

GIT_VERSION=${1:-"latest"}
USE_PPA_IF_AVAILABLE=${2:-"false"}

GIT_CORE_PPA_ARCHIVE_GPG_KEY=E1DD270288B4E6030699E45FA1715D88E1DF1F24
GPG_KEY_SERVERS="keyserver hkp://keyserver.ubuntu.com:80
keyserver hkps://keys.openpgp.org
keyserver hkp://keyserver.pgp.com"

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

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

# Import the specified key in a variable name passed in as 
receive_gpg_keys() {
    get_common_setting $1
    local keys=${!1}
    get_common_setting GPG_KEY_SERVERS true
    local keyring_args=""
    if [ ! -z "$2" ]; then
        mkdir -p "$(dirname \"$2\")"
        keyring_args="--no-default-keyring --keyring $2"
    fi

    # Use a temporary locaiton for gpg keys to avoid polluting image
    export GNUPGHOME="/tmp/tmp-gnupg"
    mkdir -p ${GNUPGHOME}
    chmod 700 ${GNUPGHOME}
    echo -e "disable-ipv6\n${GPG_KEY_SERVERS}" > ${GNUPGHOME}/dirmngr.conf
    # GPG key download sometimes fails for some reason and retrying fixes it.
    local retry_count=0
    local gpg_ok="false"
    set +e
    until [ "${gpg_ok}" = "true" ] || [ "${retry_count}" -eq "5" ]; 
    do
        echo "(*) Downloading GPG key..."
        ( echo "${keys}" | xargs -n 1 gpg -q ${keyring_args} --recv-keys) 2>&1 && gpg_ok="true"
        if [ "${gpg_ok}" != "true" ]; then
            echo "(*) Failed getting key, retring in 10s..."
            (( retry_count++ ))
            sleep 10s
        fi
    done
    set -e
    if [ "${gpg_ok}" = "false" ]; then
        echo "(!) Failed to install rvm."
        exit 1
    fi
}

# Function to run apt-get if needed
apt_get_update_if_needed()
{
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

# Source /etc/os-release to get OS info
. /etc/os-release
# If ubuntu, PPAs allowed, and latest - install from there
if ([ "${GIT_VERSION}" = "latest" ] || [ "${GIT_VERSION}" = "lts" ] || [ "${GIT_VERSION}" = "current" ]) && [ "${ID}" = "ubuntu" ] && [ "${USE_PPA_IF_AVAILABLE}" = "true" ]; then
    echo "Using PPA to install latest git..."
    check_packages apt-transport-https curl ca-certificates gnupg2
    receive_gpg_keys GIT_CORE_PPA_ARCHIVE_GPG_KEY /usr/share/keyrings/gitcoreppa-archive-keyring.gpg
    echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gitcoreppa-archive-keyring.gpg] http://ppa.launchpad.net/git-core/ppa/ubuntu ${VERSION_CODENAME} main\ndeb-src [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gitcoreppa-archive-keyring.gpg] http://ppa.launchpad.net/git-core/ppa/ubuntu ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/git-core-ppa.list
    apt-get update
    apt-get -y install --no-install-recommends git 
    rm -rf "/tmp/tmp-gnupg"
    exit 0
fi

# Install required packages to build if missing
check_packages build-essential curl ca-certificates tar gettext libssl-dev zlib1g-dev libcurl?-openssl-dev libexpat1-dev

# Partial version matching
if [ "$(echo "${GIT_VERSION}" | grep -o '\.' | wc -l)" != "2" ]; then
    requested_version="${GIT_VERSION}"
    version_list="$(curl -sSL -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/git/git/tags" | grep -oP '"name":\s*"v\K[0-9]+\.[0-9]+\.[0-9]+"' | tr -d '"' | sort -rV )"
    if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "lts" ] || [ "${requested_version}" = "current" ]; then
        GIT_VERSION="$(echo "${version_list}" | head -n 1)"
    else
        set +e
        GIT_VERSION="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
        set -e
    fi
    if [ -z "${GIT_VERSION}" ] || ! echo "${version_list}" | grep "^${GIT_VERSION//./\\.}$" > /dev/null 2>&1; then
        echo "Invalid git version: ${requested_version}" >&2
        exit 1
    fi
fi

echo "Downloading source for ${GIT_VERSION}..."
curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz | tar -xzC /tmp 2>&1
echo "Building..."
cd /tmp/git-${GIT_VERSION}
make -s prefix=/usr/local all && make -s prefix=/usr/local install 2>&1
rm -rf /tmp/git-${GIT_VERSION}
echo "Done!"
