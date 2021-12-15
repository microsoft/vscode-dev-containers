#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/dotnet.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./dotnet-debian.sh [dotnet version] [dotnet runtime only] [non-root user] [add TARGET_INSTALL_PATH to rc files flag] [install path] [access group name]

DOTNET_VERSION=${1:-"latest"}
DOTNET_RUNTIME_ONLY=${2:-"false"}
USERNAME=${3:-"automatic"}
UPDATE_RC=${4:-"true"}
TARGET_INSTALL_PATH=${5:-"/usr/local/dotnet"}
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

# Add TARGET_INSTALL_PATH variable into PATH in bashrc/zshrc files.
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

# Convert string to lowercase.
# args:
# string to convert - $1
to_lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Get latest available dotnet version
# args:
# sdk_or_runtime - $1
get_latest_version() {
    local sdk_or_runtime="$1" 

    if [ "${DOTNET_VERSION}" = "latest" ]; then
        DOTNET_VERSION="6.0"
    fi

    local url="https://dotnetcli.blob.core.windows.net/dotnet/${sdk_or_runtime}/${DOTNET_VERSION}/latest.version"
    latest_version=$(curl -sSL "${url}")

    if [[ -n "${latest_version}" ]] && [[ ! "${latest_version}" = *"Error"* ]]; then
        echo "${latest_version}"
    else
        err "Unsupported Dotnet ${sdk_or_runtime} version ${DOTNET_VERSION}."
        exit 1
    fi
}

# Create and return url of where to download dotnet runtime or sdk.
# args:
# sdk_or_runtime - $1
# dotnet version - $2
# system architecture - $3
get_download_link() {
    local sdk_or_runtime="$1"
    local full_version="$2"
    local arch="$3"
    download_link="https://dotnetcli.azureedge.net/dotnet/${sdk_or_runtime}/${full_version}/dotnet-$(to_lowercase "${sdk_or_runtime}")-${full_version}-linux-${arch}.tar.gz"
    
    echo "${download_link}"
}

# Get binaries' filename from the path elements in the download url
# args:
# binary_download_link - $1
get_filename_from_url() {
    local binary_download_link="$1"
    
    IFS='/'
    read -ra pathElems <<< "${binary_download_link}"
    count=${#pathElems[@]}
    binary_file_name="${pathElems[count-1]}"
    unset IFS;

    echo "${binary_file_name}"
}

###########################
# Start Dotnet installation
###########################

export DEBIAN_FRONTEND=noninteractive

# Check listed package dependecies and install them if they are not already installed. 
# NOTE: icu-devtools is a small package with similar dependecies to dotnet. 
#       It will install the appropriate dependencies based on the OS:
#         - libgcc-s1 OR libgcc1 depending on OS
#         - the latest libicuXX depending on OS (eg libicu57 for stretch)
#         - also installs libc6 and libstdc++6 which are required by dotnet 
check_packages curl ca-certificates tar icu-devtools libgssapi-krb5-2 libssl1.1 zlib1g

# Set architecture variable to current user's architecture (x64 or ARM64).
architecture="$(uname -m)"
case $architecture in
    x86_64) architecture="x64";;
    aarch64 | armv8*) architecture="arm64";;
    *) err "Architecture ${architecture} unsupported"; exit 1 ;;
esac

# Get the latest version for dotnet Runtime for use in generating the checksum URL 
runtime_full_version=$(get_latest_version "Runtime")

# Determine if the user wants to download dotnet Runtime only, or dotnet SDK & Runtime
# and set the appropriate variables.
if [ "${DOTNET_RUNTIME_ONLY}" = "true" ]; then
    DOTNET_SDK_OR_RUNTIME="Runtime"
    DOTNET_FULL_VERSION="${runtime_full_version}"
elif [ "${DOTNET_RUNTIME_ONLY}" = "false" ]; then
    DOTNET_SDK_OR_RUNTIME="Sdk"
    DOTNET_FULL_VERSION=$(get_latest_version "Sdk")
else
    err "Expected true for installing dotnet Runtime only or false for installing SDK and Runtime. Received ${DOTNET_RUNTIME_ONLY}."
    exit 1
fi

# Install the CLI
echo "(*) Installing dotnet CLI..."

# Setup the access group and add the user to it.
umask 0002
if ! cat /etc/group | grep -e "^${ACCESS_GROUP}:" > /dev/null 2>&1; then
    groupadd -r "${ACCESS_GROUP}"
fi
usermod -a -G "${ACCESS_GROUP}" "${USERNAME}"

# Get download link for dotnet binaries from azureedge.
binary_download_link=$(get_download_link "${DOTNET_SDK_OR_RUNTIME}" "${DOTNET_FULL_VERSION}" "${architecture}")
echo "DOWNLOAD LINK: ${binary_download_link}"


# Download the dotnet binaries.
binary_file_name=$(get_filename_from_url "${binary_download_link}")
echo "BINARY FILE NAME: ${binary_file_name}"
echo "DOWNLOADING BINARIES..."
TMP_DIR="/tmp/dotnetinstall"
mkdir -p "${TMP_DIR}"
curl -sSL "${binary_download_link}" -o "${TMP_DIR}/${binary_file_name}"

# Get checksum from dotnet CLI blob storage using the runtime version and
# run validation (sha512sum) of checksum against the expected list of checksums.
echo "FETCH AND VERIFY CHECKSUM"
curl -sSL "https://dotnetcli.blob.core.windows.net/dotnet/checksums/${runtime_full_version}-sha.txt" -o "${TMP_DIR}/checksums.txt"
grep "${binary_file_name}" "${TMP_DIR}/checksums.txt" | sed 's/\r$//' > "${TMP_DIR}/${binary_file_name}.sha512"
cd "${TMP_DIR}/"
sha512sum -c "${binary_file_name}.sha512"

# Extract binaries and add to path.
mkdir -p "${TARGET_INSTALL_PATH}"
echo "Extract Binary to ${TARGET_INSTALL_PATH}"
tar -xzf "${TMP_DIR}/${binary_file_name}" -C "${TARGET_INSTALL_PATH}" --strip-components=1

# Add DOTNET_PATH variable and bin directory into PATH in bashrc/zshrc files (unless disabled).
updaterc "$(cat << EOF
export DOTNET_PATH="${TARGET_INSTALL_PATH}"
if [[ "\${PATH}" != *"\${DOTNET_PATH}"* ]]; then export PATH="\${PATH}:\${DOTNET_PATH}"; fi
EOF
)"

# Give write permissions to the user.
chown -R ":${ACCESS_GROUP}" "${TARGET_INSTALL_PATH}"
chmod g+r+w+s "${TARGET_INSTALL_PATH}"
chmod -R g+r+w "${TARGET_INSTALL_PATH}"

echo "Done!"