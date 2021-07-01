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

TERRAFORM_PGP_KEYID=72D7468F
TFLINT_PGP_KEYID=8CE69160EB3F2FE9

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Install curl, gnupg2, coreutils, unzip if missing
if ! dpkg -s curl ca-certificates gnupg2 coreutils unzip > /dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends curl ca-certificates gnupg2 coreutils unzip
fi

if [ "${TERRAFORM_VERSION}" = "latest" ] || [ "${TERRAFORM_VERSION}" = "lts" ] || [ "${TERRAFORM_VERSION}" = "current" ]; then
    TERRAFORM_VERSION=$(curl -sSL https://releases.hashicorp.com/terraform/ | grep -m1 -oE '>terraform_[0-9]+\.[0-9]+\.[0-9]+<' | sed 's/^>terraform_\(.*\)<$/\1/')
fi
if [ "${TFLINT_VERSION}" = "latest" ] || [ "${TFLINT_VERSION}" = "lts" ] || [ "${TFLINT_VERSION}" = "current" ]; then
    TFLINT_VERSION=$(basename "$(curl -fsSL -o /dev/null -w "%{url_effective}" https://github.com/terraform-linters/tflint/releases/latest)")
fi
if [ "${TFLINT_VERSION::1}" != 'v' ]; then
    TFLINT_VERSION="v${TFLINT_VERSION}"
fi
if [ "${TERRAGRUNT_VERSION}" = "latest" ] || [ "${TERRAGRUNT_VERSION}" = "lts" ] || [ "${TERRAGRUNT_VERSION}" = "current" ]; then
    TERRAGRUNT_VERSION=$(basename "$(curl -fsSL -o /dev/null -w "%{url_effective}" https://github.com/gruntwork-io/terragrunt/releases/latest)")
fi
if [ "${TERRAGRUNT_VERSION::1}" != 'v' ]; then
    TERRAGRUNT_VERSION="v${TERRAGRUNT_VERSION}"
fi

mkdir -p /tmp/tf-downloads
cd /tmp/tf-downloads

# Get checksum signing keys and verify them (if possible)
export GNUPGHOME="/tmp/tf-downloads/gnupg"
mkdir -p ${GNUPGHOME}
chmod 700 ${GNUPGHOME}
cat << 'EOF' > /tmp/tf-downloads/gnupg/dirmngr.conf
disable-ipv6
keyserver hkps://keys.openpgp.org
keyserver hkp://keyserver.ubuntu.com:80
keyserver hkp://keyserver.pgp.com
EOF
RETRY_COUNT=0
GPG_OK="false"
set +e
until [ "${GPG_OK}" = "true" ] || [ "${RETRY_COUNT}" -eq "5" ]; 
do
    echo "(*) Downloading GPG keys..."
    gpg --recv-keys ${TERRAFORM_PGP_KEYID} 2>&1 && GPG_OK="true"
    if [ "${GPG_OK}" != "true" ]; then
        echo "(*) Failed getting key, retring in 10s..."
        (( RETRY_COUNT++ ))
        sleep 10s
    fi
done
set -e
if [ "${GPG_OK}" = "false" ]; then
    echo "(!) Failed to install Terraform utilities."
    exit 1
fi

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
        curl -sSL -o terraform_SHA256SUMS https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS 
        curl -sSL -o terraform_SHA256SUMS.sig https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.${TERRAFORM_PGP_KEYID}.sig
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
    curl -sSL -o /tmp/tf-downloads/${TFLINT_FILENAME} https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/${TFLINT_FILENAME}
    if [ "${TFLINT_SHA256}" != "dev-mode" ]; then
        if [ "${TFLINT_SHA256}" = "automatic" ]; then
            curl -sSL -o tflint_key https://raw.githubusercontent.com/terraform-linters/tflint/master/${TFLINT_PGP_KEYID}.key
            gpg -q --import tflint_key
            curl -sSL -o tflint_checksums.txt https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/checksums.txt
            curl -sSL -o tflint_checksums.txt.sig https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/checksums.txt.sig
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
    curl -sSL -o /tmp/tf-downloads/${TERRAGRUNT_FILENAME} https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/${TERRAGRUNT_FILENAME}
    if [ "${TERRAGRUNT_SHA256}" != "dev-mode" ]; then
        if [ "${TERRAGRUNT_SHA256}" = "automatic" ]; then
            curl -sSL -o terragrunt_SHA256SUMS https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/SHA256SUMS
        else
            echo "${TERRAGRUNT_SHA256} *${TERRAGRUNT_FILENAME}" > terragrunt_SHA256SUMS
        fi
        sha256sum --ignore-missing -c terragrunt_SHA256SUMS
    fi
    chmod a+x /tmp/tf-downloads/${TERRAGRUNT_FILENAME}
    mv -f /tmp/tf-downloads/${TERRAGRUNT_FILENAME} /usr/local/bin/terragrunt
fi

rm -rf /tmp/tf-downloads
echo "Done!"
