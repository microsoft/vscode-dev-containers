#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/terraform.md
#
# Syntax: ./terraform-debian.sh [terraform version] [tflint version]

TERRAFORM_VERSION=${1:-"latest"}
TFLINT_VERSION=${2:-"latest"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ "${TERRAFORM_VERSION}" = "latest" ] || [ "${TERRAFORM_VERSION}" = "lts" ] || [ "${TERRAFORM_VERSION}" = "current" ]; then
    TERRAFORM_VERSION=$(curl -sSL https://releases.hashicorp.com/terraform/ | grep -m1 -oE '>terraform_[0-9]+\.[0-9]+\.[0-9]+<' | sed 's/^>terraform_\(.*\)<$/\1/')
fi

if [ "${TFLINT_VERSION}" = "latest" ] || [ "${TFLINT_VERSION}" = "lts" ] || [ "${TFLINT_VERSION}" = "current" ]; then
    LATEST_RELEASE=$(curl -sSL -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/terraform-linters/tflint/releases?per_page=1&page=1")
    TFLINT_VERSION=$(echo ${LATEST_RELEASE} | grep -oE 'tag_name":\s*"v[^"]+' | sed -n '/tag_name":\s*"v/s///p')
fi

# Install curl, unzip if missing
if ! dpkg -s curl ca-certificates unzip > /dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends curl ca-certificates unzip
fi

# Install Terraform, tflint
echo "Downloading terraform..."
mkdir -p /tmp/tf-downloads
curl -sSL -o /tmp/tf-downloads/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip /tmp/tf-downloads/terraform.zip
mv -f terraform /usr/local/bin/

if [ "${TFLINT_VERSION}" != "none" ]; then
    echo "Downloading tflint..."
    curl -sSL -o /tmp/tf-downloads/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip
    unzip /tmp/tf-downloads/tflint.zip
    mv -f tflint /usr/local/bin/
fi

rm -rf /tmp/tf-downloads
echo "Done!"
