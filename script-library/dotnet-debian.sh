#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/dotnet.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./dotnet-debian.sh [.NET version] [.NET runtime only] [non-root user] [add TARGET_DOTNET_ROOT to rc files flag] [.NET root] [access group name]

DOTNET_VERSION=${1:-"latest"}
DOTNET_RUNTIME_ONLY=${2:-"false"}
USERNAME=${3:-"automatic"}
UPDATE_RC=${4:-"true"}
TARGET_DOTNET_ROOT=${5:-"/usr/local/dotnet"}
ACCESS_GROUP=${6:-"dotnet"}

MICROSOFT_GPG_KEYS_URI="https://packages.microsoft.com/keys/microsoft.asc"
DOTNET_ARCHIVE_ARCHITECTURES="amd64"
DOTNET_ARCHIVE_VERSION_CODENAMES="buster bullseye bionic focal hirsute"
# Feed URI sourced from the official dotnet-install.sh
# https://github.com/dotnet/install-scripts/blob/1b98b94a6f6d81cc4845eb88e0195fac67caa0a6/src/dotnet-install.sh#L1342-L1343
DOTNET_CDN_FEED_URI="https://dotnetcli.azureedge.net"

# Exit on failure.
set -e

# Setup STDERR.
err() {
    echo "(!) $*" >&2
}

# Ensure the appropriate root user is running the script.
if [ "$(id -u)" -ne 0 ]; then
    err 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Determine the appropriate non-root user.
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
            USERNAME="${CURRENT_USER}"
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

###################
# Helper Functions
###################

# Cleanup temporary directory and associated files when exiting the script.
cleanup() {
    EXIT_CODE=$?
    set +e
    if [[ -n "${TMP_DIR}" ]]; then
        echo "Executing cleanup of tmp files"
        rm -Rf "${TMP_DIR}"
    fi
    exit $EXIT_CODE
}
trap cleanup EXIT

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

# Add TARGET_DOTNET_ROOT variable into PATH in bashrc/zshrc files.
updaterc()  {
    if [ "${UPDATE_RC}" = "true" ]; then
        echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
        if [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
            echo -e "$1" >> /etc/bash.bashrc
        fi
        if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
            echo -e "$1" >> /etc/zsh/zshrc
        fi
    fi
}

# Run apt-get if needed.
apt_get_update_if_needed() {
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

# Check if packages are installed and installs them if not.
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Get appropriate architecture name for .NET binaries for the target OS
get_architecture_name_for_target_os() {
    local architecture
    architecture="$(uname -m)"
    case $architecture in
        x86_64) architecture="x64";;
        aarch64 | armv8*) architecture="arm64";;
        *) err "Architecture ${architecture} unsupported"; exit 1 ;;
    esac

    echo "${architecture}"
}

# Soft version matching that resolves a version for a given package in the *current apt-cache*
# Return value is stored in first argument (the unprocessed version)
apt_cache_package_and_version_soft_match() {
    # Version
    local version_variable_name="$1"
    local requested_version=${!version_variable_name}
    # Package Name
    local package_variable_name="$2"
    local partial_package_name=${!package_variable_name}
    local package_name
    # Exit on no match?
    local exit_on_no_match="${3:-true}"
    local major_minor_version

    major_minor_version="$(echo "${requested_version}" | cut -d "." --field=1,2)"
    package_name="$(apt-cache search "${partial_package_name}-[0-9].[0-9]" | awk -F" - " '{print $1}' | grep -m 1 "${partial_package_name}-${major_minor_version}")"

    # Ensure we've exported useful variables
    . /etc/os-release
    local architecture="$(dpkg --print-architecture)"
    
    dot_escaped="${requested_version//./\\.}"
    dot_plus_escaped="${dot_escaped//+/\\+}"
    # Regex needs to handle debian package version number format: https://www.systutorials.com/docs/linux/man/5-deb-version/
    version_regex="^(.+:)?${dot_plus_escaped}([\\.\\+ ~:-]|$)"
    set +e # Don't exit if finding version fails - handle gracefully
        fuzzy_version="$(apt-cache madison ${package_name} | awk -F"|" '{print $2}' | sed -e 's/^[ \t]*//' | grep -E -m 1 "${version_regex}")"
    set -e
    if [ -z "${fuzzy_version}" ]; then
        echo "(!) No full or partial for package \"${package_name}\" match found in apt-cache for \"${requested_version}\" on OS ${ID} ${VERSION_CODENAME} (${architecture})."

        if $exit_on_no_match; then
            echo "Available versions:"
            apt-cache madison ${package_name} | awk -F"|" '{print $2}' | grep -oP '^(.+:)?\K.+'
            exit 1 # Fail entire script
        else
            echo "Continuing to fallback method (if available)"
            return 1;
        fi
    fi

    # Globally assign fuzzy_version to this value
    # Use this value as the return value of this function
    declare -g ${version_variable_name}="=${fuzzy_version}"
    echo "${version_variable_name} ${!version_variable_name}"

    # Globally assign package to this value
    # Use this value as the return value of this function
    declare -g ${package_variable_name}="${package_name}"
    echo "${package_variable_name} ${!package_variable_name}"
}

# Install .NET CLI using apt-get package installer
install_using_apt() {
    local sdk_or_runtime="$1"
    local dotnet_major_minor_version
    export DOTNET_PACKAGE="dotnet-${sdk_or_runtime}"

    # Install dependencies
    check_packages apt-transport-https curl ca-certificates gnupg2 dirmngr

    # Import key safely and import Microsoft apt repo
    get_common_setting MICROSOFT_GPG_KEYS_URI
    curl -sSL ${MICROSOFT_GPG_KEYS_URI} | gpg --dearmor > /usr/share/keyrings/microsoft-archive-keyring.gpg
    echo "deb [arch=${architecture} signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/microsoft-${ID}-${VERSION_CODENAME}-prod ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/microsoft.list
    apt-get update

    if [ "${DOTNET_VERSION}" = "latest" ] || [ "${DOTNET_VERSION}" = "lts" ]; then
        DOTNET_VERSION=""
        DOTNET_PACKAGE="${DOTNET_PACKAGE}-6.0"
    else
        # Sets DOTNET_VERSION and DOTNET_PACKAGE if matches found. 
        apt_cache_package_and_version_soft_match DOTNET_VERSION DOTNET_PACKAGE false
        if [ "$?" != 0 ]; then
            return 1
        fi
    fi

    if ! (apt-get install -yq ${DOTNET_PACKAGE}${DOTNET_VERSION}); then
        return 1
    fi
}

# Find and extract .NET binary download details based on user-requested version
# args:
# sdk_or_runtime $1
# exports:
# DOTNET_DOWNLOAD_URL
# DOTNET_DOWNLOAD_HASH
# DOTNET_DOWNLOAD_NAME
get_full_version_details() {
    local sdk_or_runtime="$1"
    local architecture
    local dotnet_channel_version
    local dotnet_releases_url
    local dotnet_releases_json
    local dotnet_latest_version
    local dotnet_download_details

    export DOTNET_DOWNLOAD_URL
    export DOTNET_DOWNLOAD_HASH
    export DOTNET_DOWNLOAD_NAME

    # Set architecture variable to current user's architecture (x64 or ARM64).
    architecture="$(get_architecture_name_for_target_os)"

    # Set DOTNET_VERSION to empty string to ensure jq includes all .NET versions in reverse sort below 
    if [ "${DOTNET_VERSION}" = "latest" ]; then
        DOTNET_VERSION=""
    fi

    dotnet_patchless_version="$(echo "${DOTNET_VERSION}" | cut -d "." --field=1,2)"

    set +e
    dotnet_channel_version="$(curl -s "${DOTNET_CDN_FEED_URI}/dotnet/release-metadata/releases-index.json" | jq -r --arg channel_version "${dotnet_patchless_version}" '[."releases-index"[]] | sort_by(."channel-version") | reverse | map( select(."channel-version" | startswith($channel_version))) | first | ."channel-version"')"
    set -e

    # Construct the releases URL using the official channel-version if one was found.  Otherwise make a best-effort using the user input.
    if [ -n "${dotnet_channel_version}" ] && [ "${dotnet_channel_version}" != "null" ]; then
        dotnet_releases_url="${DOTNET_CDN_FEED_URI}/dotnet/release-metadata/${dotnet_channel_version}/releases.json"
    else
        dotnet_releases_url="${DOTNET_CDN_FEED_URI}/dotnet/release-metadata/${dotnet_patchless_version}/releases.json"
    fi

    set +e
    dotnet_releases_json="$(curl -s "${dotnet_releases_url}")"
    set -e
    
    if [ -n "${dotnet_releases_json}" ] && [[ ! "${dotnet_releases_json}" = *"Error"* ]]; then
        dotnet_latest_version="$(echo "${dotnet_releases_json}" | jq -r --arg sdk_or_runtime "${sdk_or_runtime}" '."latest-\($sdk_or_runtime)"')"
        # If user-specified version has 2 or more dots, use it as is.  Otherwise use latest version.
        if [ "$(echo "${DOTNET_VERSION}" | grep -o "\." | wc -l)" -lt "2" ]; then
            DOTNET_VERSION="${dotnet_latest_version}"
        fi

        dotnet_download_details="$(echo "${dotnet_releases_json}" |  jq -r --arg sdk_or_runtime "${sdk_or_runtime}" --arg dotnet_version "${DOTNET_VERSION}" --arg arch "${architecture}" '.releases[]."\($sdk_or_runtime)" | select(.version==$dotnet_version) | .files[] | select(.name=="dotnet-\($sdk_or_runtime)-linux-\($arch).tar.gz")')"
        if [ -n "${dotnet_download_details}" ]; then
            echo "Found .NET binary version ${DOTNET_VERSION}"
            DOTNET_DOWNLOAD_URL="$(echo "${dotnet_download_details}" | jq -r '.url')"
            DOTNET_DOWNLOAD_HASH="$(echo "${dotnet_download_details}" | jq -r '.hash')"
            DOTNET_DOWNLOAD_NAME="$(echo "${dotnet_download_details}" | jq -r '.name')"
        else
            err "Unable to find .NET binary for version ${DOTNET_VERSION}"
            exit 1
        fi
    else
        err "Unable to find .NET release details for version ${DOTNET_VERSION} at ${dotnet_releases_url}"
        exit 1
    fi
}

# Install .NET CLI using the .NET releases url
install_using_dotnet_releases_url() {
    local sdk_or_runtime="$1"

    # Check listed package dependecies and install them if they are not already installed. 
    # NOTE: icu-devtools is a small package with similar dependecies to .NET. 
    #       It will install the appropriate dependencies based on the OS:
    #         - libgcc-s1 OR libgcc1 depending on OS
    #         - the latest libicuXX depending on OS (eg libicu57 for stretch)
    #         - also installs libc6 and libstdc++6 which are required by .NET 
    check_packages curl ca-certificates tar jq icu-devtools libgssapi-krb5-2 libssl1.1 zlib1g

    get_full_version_details "${sdk_or_runtime}"
    # exports DOTNET_DOWNLOAD_URL, DOTNET_DOWNLOAD_HASH, DOTNET_DOWNLOAD_NAME
    echo "DOWNLOAD LINK: ${DOTNET_DOWNLOAD_URL}"

    # Setup the access group and add the user to it.
    umask 0002
    if ! cat /etc/group | grep -e "^${ACCESS_GROUP}:" > /dev/null 2>&1; then
        groupadd -r "${ACCESS_GROUP}"
    fi
    usermod -a -G "${ACCESS_GROUP}" "${USERNAME}"

    # Download the .NET binaries.
    echo "DOWNLOADING BINARY..."
    TMP_DIR="/tmp/dotnetinstall"
    mkdir -p "${TMP_DIR}"
    curl -sSL "${DOTNET_DOWNLOAD_URL}" -o "${TMP_DIR}/${DOTNET_DOWNLOAD_NAME}"

    # Get checksum from .NET CLI blob storage using the runtime version and
    # run validation (sha512sum) of checksum against the expected checksum hash.
    echo "VERIFY CHECKSUM"
    cd "${TMP_DIR}"
    echo "${DOTNET_DOWNLOAD_HASH} *${DOTNET_DOWNLOAD_NAME}" | sha512sum -c -

    # Extract binaries and add to path.
    mkdir -p "${TARGET_DOTNET_ROOT}"
    echo "Extract Binary to ${TARGET_DOTNET_ROOT}"
    tar -xzf "${TMP_DIR}/${DOTNET_DOWNLOAD_NAME}" -C "${TARGET_DOTNET_ROOT}" --strip-components=1

    updaterc "$(cat << EOF
    export DOTNET_ROOT="${TARGET_DOTNET_ROOT}"
    if [[ "\${PATH}" != *"\${DOTNET_ROOT}"* ]]; then export PATH="\${PATH}:\${DOTNET_ROOT}"; fi
EOF
    )"
    
    # Give write permissions to the user.
    chown -R ":${ACCESS_GROUP}" "${TARGET_DOTNET_ROOT}"
    chmod g+r+w+s "${TARGET_DOTNET_ROOT}"
    chmod -R g+r+w "${TARGET_DOTNET_ROOT}"
}

###########################
# Start .NET installation
###########################

export DEBIAN_FRONTEND=noninteractive

# Determine if the user wants to download .NET Runtime only, or .NET SDK & Runtime
# and set the appropriate variables.
if [ "${DOTNET_RUNTIME_ONLY}" = "true" ]; then
    DOTNET_SDK_OR_RUNTIME="runtime"
elif [ "${DOTNET_RUNTIME_ONLY}" = "false" ]; then
    DOTNET_SDK_OR_RUNTIME="sdk"
else
    err "Expected true for installing dotnet Runtime only or false for installing SDK and Runtime. Received ${DOTNET_RUNTIME_ONLY}."
    exit 1
fi

# Install the .NET CLI
echo "(*) Installing .NET CLI..."

. /etc/os-release
architecture="$(dpkg --print-architecture)"

use_dotnet_releases_url="false"
if [[ "${DOTNET_ARCHIVE_ARCHITECTURES}" = *"${architecture}"* ]] && [[  "${DOTNET_ARCHIVE_VERSION_CODENAMES}" = *"${VERSION_CODENAME}"* ]]; then
    install_using_apt "${DOTNET_SDK_OR_RUNTIME}" || use_dotnet_releases_url="true"
else
   use_dotnet_releases_url="true"
fi

if [ "${use_dotnet_releases_url}" = "true" ]; then
   install_using_dotnet_releases_url "${DOTNET_SDK_OR_RUNTIME}"
fi

echo "Done!"