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
DOTNET_RUNTIME_ONLY=${2:-"false"} #TODO: figure out how this works
USERNAME=${3:-"automatic"}
UPDATE_RC=${4:-"true"}
TARGET_INSTALL_PATH=${5:-"/opt/dotnet"}
ACCESS_GROUP=${6:-"dotnet"}

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

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

# TODO: validate inputs

updaterc() {
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

# TODO(bderusha): remove function
get_download_link_from_aka_ms() {    
    if [ "${DOTNET_VERSION}" = "latest" ] || [ "${DOTNET_VERSION}" = "lts" ]; then
        DOTNET_VERSION="6.0"
    fi

    local runtime_or_sdk="$1"

    # eval $invocation

    #quality is not supported for LTS or current channel
    # if [[ ! -z "$normalized_quality"  && ("$normalized_channel" == "LTS" || "$normalized_channel" == "current") ]]; then
    #     normalized_quality=""
    #     say_warning "Specifying quality for current or LTS channel is not supported, the quality will be ignored."
    # fi

    # say_verbose "Retrieving primary payload URL from aka.ms for channel: '$normalized_channel', quality: '$normalized_quality', product: '$normalized_product', os: '$normalized_os', architecture: '$normalized_architecture'." 

    #construct aka.ms link
    # aka_ms_link="https://aka.ms/dotnet"
    # if  [ "$internal" = true ]; then
    #     aka_ms_link="$aka_ms_link/internal"
    # fi
    # aka_ms_link="$aka_ms_link/$normalized_channel"
    # if [[ ! -z "$normalized_quality" ]]; then
    #     aka_ms_link="$aka_ms_link/$normalized_quality"
    # fi


    # TODO: fix 3.1 issue
    #   elif [[ "$runtime" == "aspnetcore" ]]; then
    #   download_link="$azure_feed/aspnetcore/Runtime/$specific_version/${pvFileName}"

    aka_ms_link="https://aka.ms/dotnet/${DOTNET_VERSION}/dotnet-${runtime_or_sdk}-linux-${architecture}.tar.gz"
    echo "Constructed aka.ms link: '$aka_ms_link'."

    #get HTTP response
    #do not pass credentials as a part of the $aka_ms_link and do not apply credentials in the get_http_header function
    #otherwise the redirect link would have credentials as well
    #it would result in applying credentials twice to the resulting link and thus breaking it, and in echoing credentials to the output as a part of redirect link
    # disable_feed_credential=true
    response="$(curl -I -sSL --retry 5 --retry-delay 2 --connect-timeout 15 $aka_ms_link)"

    echo "Received response: $response"
    # Get results of all the redirects.
    http_codes=$( echo "$response" | awk '$1 ~ /^HTTP/ {print $2}' )
    # They all need to be 301, otherwise some links are broken (except for the last, which is not a redirect but 200 or 404).
    expected_redirect=$( echo "${http_codes}" | sed '$d' | grep '301' )

    # All HTTP codes are 301 (Moved Permanently), the redirect link exists.
    if [[ -z "$expected_redirect" ]]; then
        echo "The aka.ms link '$aka_ms_link' is not valid: received HTTP code: $(echo "$broken_redirects" | paste -sd "," -)."
        return 1
    else
        aka_ms_download_link=$( echo "$response" | awk '$1 ~ /^Location/{print $2}' | tail -1 | tr -d '\r')

        if [[ -z "$aka_ms_download_link" ]]; then
            echo "The aka.ms link '$aka_ms_link' is not valid: failed to get redirect location."
            return 1
        fi

        echo "The redirect location retrieved: '$aka_ms_download_link'."
        return 0
    fi
}

# args:
# input - $1
to_lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
    return 0
}


get_latest_version() {
    if [ "${DOTNET_VERSION}" = "latest" ]; then
        DOTNET_VERSION="6.0"
    fi

    local url="https://dotnetcli.blob.core.windows.net/dotnet/$1/${DOTNET_VERSION}/latest.version"
    latest_version=$(curl -sSL "${url}")
    echo "LATEST VERSION: ${latest_version}"

    #TODO(bderusha): Add var setting for easier readability
    # if [ ! -z "${result}" ]; then declare -g $1="${result}"; fi
}

get_download_link() {
    local sdk_or_runtime="$1"
    local full_version="$2"
    local arch="$3"
    download_link="https://dotnetcli.azureedge.net/dotnet/${sdk_or_runtime}/${full_version}/dotnet-$(to_lowercase "${sdk_or_runtime}")-${full_version}-linux-${arch}.tar.gz"
    #TODO(bderusha): Add var setting for easier readability
    # if [ ! -z "${result}" ]; then declare -g $1="${result}"; fi
}

export DEBIAN_FRONTEND=noninteractive

# NOTE: icu-devtools will install the appropriate dependencies based on the OS
#       libgcc-s1 OR libgcc1 depending on OS
#       the latest libicuXX depending on OS (eg libicu57 for stretch)
#       also installs libc6 and libstdc++6 which are required by dotnet 
# NOTE: swapped libicu-dev for icu-devtools, same dependency on libicuXX but 10x smaller
check_packages curl ca-certificates tar icu-devtools libgssapi-krb5-2 libssl1.1 zlib1g

# TODO: Check this script across other OSs including ARM64-bullseye
architecture="$(uname -m)"
case $architecture in
    x86_64) architecture="x64";;
    aarch64 | armv8*) architecture="arm64";;
    *) echo "(!) Architecture $architecture unsupported"; exit 1 ;;
esac

get_latest_version "Runtime" 
runtime_full_version="${latest_version}"
get_latest_version "Sdk" 
sdk_full_version="${latest_version}"

if [ "${DOTNET_RUNTIME_ONLY}" = "true" ]; then
    DOTNET_SDK_OR_RUNTIME="Runtime"
    DOTNET_FULL_VERSION="${runtime_full_version}"
else
    DOTNET_SDK_OR_RUNTIME="Sdk"
    DOTNET_FULL_VERSION="${sdk_full_version}"
fi

# TODO: add echo statements detailing steps
echo "(*) Installing dotnet CLI..."
umask 0002
if ! cat /etc/group | grep -e "^${ACCESS_GROUP}:" > /dev/null 2>&1; then
    groupadd -r "${ACCESS_GROUP}"
fi
usermod -a -G "${ACCESS_GROUP}" "${USERNAME}"
mkdir -p "${TARGET_INSTALL_PATH}"

# use aka.ms url header for dotnet runtime to extract the correct version
# get_download_link_from_aka_ms "runtime"
# runtime_download_link="${aka_ms_download_link}"

# # TODO: Update to use "read -ra pathElems" below for 3.1 compat
# # runtime_full_version=$(echo ${runtime_download_link} | cut -d/ -f6)




# download the runtime / runtime and sdk binaries from azureedge
get_download_link "${DOTNET_SDK_OR_RUNTIME}" "${DOTNET_FULL_VERSION}" "${architecture}"
echo "DOWNLOAD LINK: ${download_link}"
binary_download_link="${download_link}"
# binary_file_name=$(echo ${binary_download_link} | cut -d/ -f7)
#get filename from the path
IFS='/'
read -ra pathElems <<< "${binary_download_link}"
count=${#pathElems[@]}
binary_file_name="${pathElems[count-1]}"
unset IFS;

echo "BINARY FILE NAME: ${binary_file_name}"
mkdir -p /tmp/dotnetinstall
curl -sSL "${binary_download_link}" -o "/tmp/dotnetinstall/${binary_file_name}"

# download checksum from dotnet CLI blob storage and
# run validation (sha512sum) of checksum against the expected list of checksums
echo "FETCH AND VERIFY CHECKSUM"
curl -sSL "https://dotnetcli.blob.core.windows.net/dotnet/checksums/${runtime_full_version}-sha.txt" -o /tmp/dotnetinstall/checksums.txt
grep "${binary_file_name}" /tmp/dotnetinstall/checksums.txt | sed 's/\r$//' > "/tmp/dotnetinstall/${binary_file_name}.sha512"
cd /tmp/dotnetinstall/
sha512sum -c "${binary_file_name}.sha512"

# extract binaries and add to path
echo "Extract Binary to ${TARGET_INSTALL_PATH}"
tar -xzf "/tmp/dotnetinstall/${binary_file_name}" -C "${TARGET_INSTALL_PATH}" --strip-components=1

# TODO: clean up tmp dir

# add access group // and set up pathing
# Add DOTNET_PATH variable and bin directory into PATH in bashrc/zshrc files (unless disabled)
updaterc "$(cat << EOF
export DOTNET_PATH="${TARGET_INSTALL_PATH}"
if [[ "\${PATH}" != *"\${DOTNET_PATH}"* ]]; then export PATH="\${PATH}:\${DOTNET_PATH}"; fi
EOF
)"
# give write permissions to user
chown -R ":${ACCESS_GROUP}" "${TARGET_INSTALL_PATH}"
chmod g+r+w+s "${TARGET_INSTALL_PATH}"
chmod -R g+r+w "${TARGET_INSTALL_PATH}"

echo "Done!"