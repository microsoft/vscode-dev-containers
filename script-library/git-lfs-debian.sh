#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/git-lfs.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./git-lfs-debian.sh [version]

GIT_LFS_VERSION=${1:-"latest"}
GIT_LFS_ARCHIVE_GPG_KEY_URI="https://packagecloud.io/github/git-lfs/gpgkey"
GIT_LFS_ARCHIVE_ARCHITECTURES="amd64"
GIT_LFS_ARCHIVE_VERSION_CODENAMES="stretch buster bionic focal"
GIT_LFS_CHECKSUM_GPG_KEYS="0x88ace9b29196305ba9947552f1ba225c0223b187 0x86cd3297749375bcf8206715f54fe648088335a9 0xaa3b3450295830d2de6db90caba67be5a5795889"
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

# Figure out correct version of a three part version number is not passed
find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    local prefix=${3:-"tags/v"}
    local separator=${4:-"."}
    local last_part_optional=${5:-"false"}    
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        local version_list="$(git ls-remote --tags ${repository} | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g ${variable_name}="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

# Import the specified key in a variable name passed in as 
receive_gpg_keys() {
    get_common_setting $1
    local keys=${!1}
    get_common_setting GPG_KEY_SERVERS true

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
        ( echo "${keys}" | xargs -n 1 gpg --recv-keys) 2>&1 && gpg_ok="true"
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

# Install git, curl, gpg, and debian-archive-keyring if missing
. /etc/os-release
check_packages curl ca-certificates gnupg2 apt-transport-https
if ! type git > /dev/null 2>&1; then
    apt_get_update_if_needed
    apt-get -y install --no-install-recommends git
fi
if [ "${ID}" = "debian" ]; then
    check_packages debian-archive-keyring
fi


# Install Git LFS
echo "Installing Git LFS..."
architecture="$(dpkg --print-architecture)"
if [[ "${GIT_LFS_ARCHIVE_ARCHITECTURES}" = *"${architecture}"* ]] && [[  "${GIT_LFS_ARCHIVE_VERSION_CODENAMES}" = *"${VERSION_CODENAME}"* ]]; then
    # Soft version matching
    if [ "${GIT_LFS_VERSION}" != "latest" ] && [ "${GIT_LFS_VERSION}" != "lts" ] && [ "${GIT_LFS_VERSION}" != "stable" ]; then
        find_version_from_git_tags GIT_LFS_VERSION "https://github.com/git-lfs/git-lfs"
        version_suffix="=${GIT_LFS_VERSION}"
    else
        version_suffix=""
    fi
    # Install
    get_common_setting GIT_LFS_ARCHIVE_GPG_KEY_URI
    curl -sSL "${GIT_LFS_ARCHIVE_GPG_KEY_URI}" | gpg --dearmor > /usr/share/keyrings/gitlfs-archive-keyring.gpg
    echo -e "deb [arch=${architecture} signed-by=/usr/share/keyrings/gitlfs-archive-keyring.gpg] https://packagecloud.io/github/git-lfs/${ID} ${VERSION_CODENAME} main\ndeb-src [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gitlfs-archive-keyring.gpg] https://packagecloud.io/github/git-lfs/${ID} ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/git-lfs.list
    apt-get install -yq git-lfs${version_suffix}
    git lfs install --skip-repo
else
    echo "No apt package for ${VERSION_CODENAME} ${architecture}. Installing manually."
    mkdir -p /tmp/git-lfs
    cd /tmp/git-lfs
    find_version_from_git_tags GIT_LFS_VERSION "https://github.com/git-lfs/git-lfs"
    git_lfs_filename="git-lfs-linux-${architecture}-v${GIT_LFS_VERSION}.tar.gz"
    curl -sSL -o "${git_lfs_filename}" "https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/${git_lfs_filename}"
    # Verify file
    curl -sSL -o "sha256sums.asc" "https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/sha256sums.asc"
    receive_gpg_keys GIT_LFS_CHECKSUM_GPG_KEYS
    gpg -q --decrypt "sha256sums.asc" > sha256sums
    sha256sum --ignore-missing -c "sha256sums"
    # Extract and install
    tar xf "${git_lfs_filename}" -C .
    ./install.sh
    rm -rf /tmp/git-lfs /tmp/tmp-gnupg
fi

echo "Done!"