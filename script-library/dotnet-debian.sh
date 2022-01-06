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

    dotnet_channel_version="$(echo "${DOTNET_VERSION}" | cut -d "." --field=1,2)"
    dotnet_releases_url="$(curl -sS https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json | jq -r --arg channel_version "${dotnet_channel_version}" '[."releases-index"[]] | sort_by(."channel-version") | reverse | map( select(."channel-version" | startswith($channel_version))) | first | ."releases.json"')"

    if [ -n "${dotnet_releases_url}" ] && [ "${dotnet_releases_url}" != "null" ]; then
        dotnet_releases_json="$(curl -sS "${dotnet_releases_url}")"
        dotnet_latest_version="$(echo "${dotnet_releases_json}" | jq -r '."latest-release"')"
        # If user-specified version has 2 or more dots, use it as is.  Otherwise use latest version.
        if [ "$(echo "${DOTNET_VERSION}" | grep -o "\." | wc -l)" -lt "2" ]; then
            DOTNET_VERSION="${dotnet_latest_version}"
        fi

        dotnet_download_details="$(echo "${dotnet_releases_json}" |  jq -r --arg sdk_or_runtime "${sdk_or_runtime}" --arg dotnet_version "${DOTNET_VERSION}" --arg arch "${architecture}" '.releases[] | select( ."release-version"==$dotnet_version) | .[$sdk_or_runtime].files[] | select(.name=="dotnet-\($sdk_or_runtime)-linux-\($arch).tar.gz")')"
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
        err "Unsupported .NET version ${DOTNET_VERSION}."
        exit 1
    fi
}

###########################
# Start .NET installation
###########################

export DEBIAN_FRONTEND=noninteractive

# Check listed package dependecies and install them if they are not already installed. 
# NOTE: icu-devtools is a small package with similar dependecies to .NET. 
#       It will install the appropriate dependencies based on the OS:
#         - libgcc-s1 OR libgcc1 depending on OS
#         - the latest libicuXX depending on OS (eg libicu57 for stretch)
#         - also installs libc6 and libstdc++6 which are required by .NET 
check_packages curl ca-certificates tar jq icu-devtools libgssapi-krb5-2 libssl1.1 zlib1g

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

get_full_version_details "${DOTNET_SDK_OR_RUNTIME}"
# exports DOTNET_DOWNLOAD_URL, DOTNET_DOWNLOAD_HASH, DOTNET_DOWNLOAD_NAME
echo "DOWNLOAD LINK: ${DOTNET_DOWNLOAD_URL}"

# Install the .NET CLI
echo "(*) Installing .NET CLI..."

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

# Add DOTNET_ROOT variable and bin directory into PATH in bashrc/zshrc files (unless disabled).
updaterc "$(cat << EOF
export DOTNET_ROOT="${TARGET_DOTNET_ROOT}"
if [[ "\${PATH}" != *"\${DOTNET_ROOT}"* ]]; then export PATH="\${PATH}:\${DOTNET_ROOT}"; fi
EOF
)"

# Give write permissions to the user.
chown -R ":${ACCESS_GROUP}" "${TARGET_DOTNET_ROOT}"
chmod g+r+w+s "${TARGET_DOTNET_ROOT}"
chmod -R g+r+w "${TARGET_DOTNET_ROOT}"

echo "Done!"