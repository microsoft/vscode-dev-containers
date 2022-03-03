#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/awscli.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./awscli-debian.sh [AWS CLI version]

set -e

AWSCLI_VERSION=${1:-"latest"}

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

verify_aws_cli_gpg_signature() {
    local filePath=$1
    local sigFilePath=$2

    get_common_setting AWSCLI_GPG_KEY
    get_common_setting AWSCLI_GPG_KEY_MATERIAL
    local awsCliPublicKeyFile=aws-cli-public-key.pem
    echo "${AWSCLI_GPG_KEY_MATERIAL}" > "${awsCliPublicKeyFile}"
    gpg --quiet --import "${awsCliPublicKeyFile}"
    (
    ) > "${awsCliPublicKeyFile}"
    gpg --quiet --import "${awsCliPublicKeyFile}"

    gpg --batch --quiet --verify "${sigFilePath}" "${filePath}"
    local status=$?

    gpg --batch --quiet --delete-keys "${AWSCLI_GPG_KEY}"
    rm "${awsCliPublicKeyFile}"

    return ${status}
}

install() {
    local scriptZipFile=awscli.zip
    local scriptSigFile=awscli.sig

    # See Linux install docs at https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
    if [ "${AWSCLI_VERSION}" != "latest" ]; then
        local versionStr=-${AWSCLI_VERSION}
    fi
    arch=$(uname -m)
    if [ "$arch" != "x86_64" -a "$arch" != "aarch64" ]; then
        echo "AWS CLI does not support machine architecture '$arch'. Please use an x86-64 or ARM64 machine."
        exit 1
    fi
    local scriptUrl=https://awscli.amazonaws.com/awscli-exe-linux-${arch}${versionStr}.zip
    curl "${scriptUrl}" -o "${scriptZipFile}"
    curl "${scriptUrl}.sig" -o "${scriptSigFile}"

    verify_aws_cli_gpg_signature "$scriptZipFile" "$scriptSigFile"
    if (( $? > 0 )); then
        echo "Could not verify GPG signature of AWS CLI install script. Make sure you provided a valid version."
        exit 1
    fi

    unzip "${scriptZipFile}"
    ./aws/install

    rm -rf ./aws
}

echo "(*) Installing AWS CLI..."

install

echo "Done!"