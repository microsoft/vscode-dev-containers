#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/powershell.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./powershell-debian.sh [version]

set -e

POWERSHELL_VERSION=${1:-"latest"}
MICROSOFT_GPG_KEYS_URI="https://packages.microsoft.com/keys/microsoft.asc"
POWERSHELL_ARCHIVE_ARCHITECTURES="amd64"
POWERSHELL_ARCHIVE_VERSION_CODENAMES="stretch buster bionic focal"
GPG_KEY_SERVERS="keyserver hkp://keyserver.ubuntu.com:80
keyserver hkps://keys.openpgp.org
keyserver hkp://keyserver.pgp.com"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

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

install_using_apt() {
    # Install dependencies
    check_packages apt-transport-https curl ca-certificates gnupg2 dirmngr
    # Import key safely (new 'signed-by' method rather than deprecated apt-key approach) and install
    get_common_setting MICROSOFT_GPG_KEYS_URI
    curl -sSL ${MICROSOFT_GPG_KEYS_URI} | gpg --dearmor > /usr/share/keyrings/microsoft-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/microsoft-${ID}-${VERSION_CODENAME}-prod ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/microsoft.list

    # Update lists
    apt-get update -yq

    # Soft version matching for CLI
    if [ "${POWERSHELL_VERSION}" = "latest" ] || [ "${POWERSHELL_VERSION}" = "lts" ] || [ "${POWERSHELL_VERSION}" = "stable" ]; then
        # Empty, meaning grab whatever "latest" is in apt repo
        version_suffix=""
    else    
        version_suffix="=$(apt-cache madison powershell | awk -F"|" '{print $2}' | sed -e 's/^[ \t]*//' | grep -E -m 1 "^(${POWERSHELL_VERSION})(\.|$|\+.*|-.*)")"

        if [ -z ${version_suffix} ] || [ ${version_suffix} = "=" ]; then
            echo "Provided POWERSHELL_VERSION (${POWERSHELL_VERSION}) was not found in the apt-cache for this package+distribution combo";
            return 1
        fi
        echo "version_suffix ${version_suffix}"
    fi

    apt-get install -yq powershell${version_suffix} || return 1
}

install_using_github() {
    # Fall back on direct download if no apt package exists in microsoft pool
    check_packages curl ca-certificates gnupg2 dirmngr libc6 libgcc1 libgssapi-krb5-2 libstdc++6 libunwind8 libuuid1 zlib1g libicu[0-9][0-9]
    if ! type git > /dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get install -y --no-install-recommends git
    fi
    if [ "${architecture}" = "amd64" ]; then
        architecture="x64"
    fi
    find_version_from_git_tags POWERSHELL_VERSION https://github.com/PowerShell/PowerShell
    powershell_filename="powershell-${POWERSHELL_VERSION}-linux-${architecture}.tar.gz"
    powershell_target_path="/opt/microsoft/powershell/$(echo ${POWERSHELL_VERSION} | grep -oE '[^\.]+' | head -n 1)"
    mkdir -p /tmp/pwsh "${powershell_target_path}"
    cd /tmp/pwsh
    curl -sSL -o "${powershell_filename}" "https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/${powershell_filename}"
    # Ugly - but only way to get sha256 is to parse release HTML. Remove newlines and tags, then look for filename followed by 64 hex characters.
    curl -sSL -o "release.html" "https://github.com/PowerShell/PowerShell/releases/tag/v${POWERSHELL_VERSION}"
    powershell_archive_sha256="$(cat release.html | tr '\n' ' ' | sed 's|<[^>]*>||g' | grep -oP "${powershell_filename}\s+\K[0-9a-fA-F]{64}" || echo '')"
    if [ -z "${powershell_archive_sha256}" ]; then
        echo "(!) WARNING: Failed to retrieve SHA256 for archive. Skipping validaiton."
    else
        echo "SHA256: ${powershell_archive_sha256}"
        echo "${powershell_archive_sha256} *${powershell_filename}" | sha256sum -c -
    fi
    tar xf "${powershell_filename}" -C "${powershell_target_path}"
    ln -s "${powershell_target_path}/pwsh" /usr/local/bin/pwsh
    rm -rf /tmp/pwsh
}

export DEBIAN_FRONTEND=noninteractive

# Source /etc/os-release to get OS info
. /etc/os-release
architecture="$(dpkg --print-architecture)"

if [[ "${POWERSHELL_ARCHIVE_ARCHITECTURES}" = *"${architecture}"* ]] && [[  "${POWERSHELL_ARCHIVE_VERSION_CODENAMES}" = *"${VERSION_CODENAME}"* ]]; then
    install_using_apt || use_github="true"
else
    use_github="true"
fi

if [ "${use_github}" = "true" ]; then
    echo "Attempting install from GitHub release..."
    install_using_github
fi

echo "Done!"