#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/terraform.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./terraform-debian.sh [terraform version] [tflint version] [terragrunt version] [terraform SHA] [tflint SHA] [terragrunt SHA]

TERRAFORM_VERSION=${1:-"latest"}
TFLINT_VERSION=${2:-"latest"}
TERRAGRUNT_VERSION=${3:-"latest"}
TERRAFORM_SHA256=${4:-"automatic"}
TFLINT_SHA256=${5:-"automatic"}
TERRAGRUNT_SHA256=${6:-"automatic"}

TERRAFORM_GPG_KEY=72D7468F
TFLINT_GPG_KEY_URI="https://raw.githubusercontent.com/terraform-linters/tflint/master/8CE69160EB3F2FE9.key"
GPG_KEY_SERVERS="keyserver hkp://keyserver.ubuntu.com:80
keyserver hkps://keys.openpgp.org
keyserver hkp://keyserver.pgp.com"

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

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
    echo $1=${!1}
}

function importGPGKeys() {
    getCommonSetting $1
    local keys=${!1}
    getCommonSetting GPG_KEY_SERVERS true

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

# Figure out correct version of a three part version number is not passed
function findVersionFromGitTags() {
    local variable_name=$1
    local requested_version=${!1}
    local repository=$2
    if [ "${requested_version}" = "none" ]; then return; fi
    local version_list="$(git ls-remote --tags ${repository} | grep -oP 'tags/v\K[0-9]+\.[0-9]+\.[0-9]+$' | sort -rV)"
    if [ "$(echo "${requested_version}" | grep -o '\.' | wc -l)" != "2" ]; then
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else 
            declare -g ${variable_name}="$(echo "${version_list}" | grep -m1 "${requested_version}")"
        fi
    fi
    if ! echo "${version_list}" | grep "^${!variable_name}$" > /dev/null 2>&1; then
        echo "Invalid ${variable_name} value: ${!variable_name}"
        exit 1
    fi
    echo "${variable_name} target: ${!variable_name}"
}

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

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Install dependencies if missing
if ! dpkg -s curl ca-certificates gnupg2 dirmngr coreutils unzip > /dev/null 2>&1; then
    apt-get-update-if-needed
    apt-get -y install --no-install-recommends curl ca-certificates gnupg2 dirmngr coreutils unzip
fi
if ! type git > /dev/null 2>&1; then
    apt-get-update-if-needed
    apt-get -y install --no-install-recommends git
fi


# Verify requested version is available, convert latest
findVersionFromGitTags TERRAFORM_VERSION 'https://github.com/hashicorp/terraform'
findVersionFromGitTags TFLINT_VERSION 'https://github.com/terraform-linters/tflint'
findVersionFromGitTags TERRAGRUNT_VERSION 'https://github.com/gruntwork-io/terragrunt'

mkdir -p /tmp/tf-downloads
cd /tmp/tf-downloads

ARCHITECTURE="$(uname -m)"
case $ARCHITECTURE in
    x86_64) ARCHITECTURE="amd64";;
    aarch64 | armv8*) ARCHITECTURE="arm64";;
    aarch32 | armv7* | armvhf*) ARCHITECTURE="arm";;
    i?86) ARCHITECTURE="386";;
    *) echo "(!) Architecture $ARCHITECTURE unsupported"; exit 1 ;;
esac

# Install Terraform, tflint, Terragrunt
echo "Downloading terraform..."
TERRAFORM_FILENAME="terraform_${TERRAFORM_VERSION}_linux_${ARCHITECTURE}.zip"
curl -sSL -o ${TERRAFORM_FILENAME} https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_FILENAME}
if [ "${TERRAFORM_SHA256}" != "dev-mode" ]; then
    if [ "${TERRAFORM_SHA256}" = "automatic" ]; then
        importGPGKeys TERRAFORM_GPG_KEY
        curl -sSL -o terraform_SHA256SUMS https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS 
        curl -sSL -o terraform_SHA256SUMS.sig https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.${TERRAFORM_GPG_KEY}.sig
        gpg --verify terraform_SHA256SUMS.sig terraform_SHA256SUMS
    else
        echo "${TERRAFORM_SHA256} *${TERRAFORM_FILENAME}" > terraform_SHA256SUMS
    fi
    sha256sum --ignore-missing -c terraform_SHA256SUMS
fi
unzip ${TERRAFORM_FILENAME}
mv -f terraform /usr/local/bin/

if [ "${TFLINT_VERSION}" != "none" ]; then
    echo "Downloading tflint..."
    TFLINT_FILENAME="tflint_linux_${ARCHITECTURE}.zip"
    curl -sSL -o /tmp/tf-downloads/${TFLINT_FILENAME} https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/${TFLINT_FILENAME}
    if [ "${TFLINT_SHA256}" != "dev-mode" ]; then
        if [ "${TFLINT_SHA256}" = "automatic" ]; then
            getCommonSetting TFLINT_GPG_KEY_URI
            curl -sSL -o tflint_key "${TFLINT_GPG_KEY_URI}"
            gpg -q --import tflint_key
            curl -sSL -o tflint_checksums.txt https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/checksums.txt
            curl -sSL -o tflint_checksums.txt.sig https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/checksums.txt.sig
            gpg --verify tflint_checksums.txt.sig tflint_checksums.txt
        else
            echo "${TFLINT_SHA256} *${TFLINT_FILENAME}" > tflint_checksums.txt
        fi
        sha256sum --ignore-missing -c tflint_checksums.txt
    fi
    unzip /tmp/tf-downloads/${TFLINT_FILENAME}
    mv -f tflint /usr/local/bin/
fi
if [ "${TERRAGRUNT_VERSION}" != "none" ]; then
    echo "Downloading Terragrunt..."
    TERRAGRUNT_FILENAME="terragrunt_linux_${ARCHITECTURE}"
    curl -sSL -o /tmp/tf-downloads/${TERRAGRUNT_FILENAME} https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/${TERRAGRUNT_FILENAME}
    if [ "${TERRAGRUNT_SHA256}" != "dev-mode" ]; then
        if [ "${TERRAGRUNT_SHA256}" = "automatic" ]; then
            curl -sSL -o terragrunt_SHA256SUMS https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/SHA256SUMS
        else
            echo "${TERRAGRUNT_SHA256} *${TERRAGRUNT_FILENAME}" > terragrunt_SHA256SUMS
        fi
        sha256sum --ignore-missing -c terragrunt_SHA256SUMS
    fi
    chmod a+x /tmp/tf-downloads/${TERRAGRUNT_FILENAME}
    mv -f /tmp/tf-downloads/${TERRAGRUNT_FILENAME} /usr/local/bin/terragrunt
fi

rm -rf /tmp/tf-downloads ${GNUPGHOME}
echo "Done!"
