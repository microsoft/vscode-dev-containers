#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/maven.md
#
# Syntax: ./maven-debian.sh [maven version] [SDKMAN_DIR] [non-root user] [Update rc files flag]

MAVEN_VERSION=${1:-"latest"}
export SDKMAN_DIR=${2:-"/usr/local/sdkman"}
USERNAME=${3:-"automatic"}
UPDATE_RC=${4:-"true"}

set -e

 # Blank will install latest maven version
if [ "${MAVEN_VERSION}" = "lts" ] || [ "${MAVEN_VERSION}" = "current" ] || [ "${MAVEN_VERSION}" = "latest" ]; then
    MAVEN_VERSION=""
fi

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

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

function updaterc() {
    if [ "${UPDATE_RC}" = "true" ]; then
        echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
        echo -e "$1" | tee -a /etc/bash.bashrc >> /etc/zsh/zshrc
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Install curl, zip, unzip if missing
if ! dpkg -s curl ca-certificates zip unzip sed > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends curl ca-certificates zip unzip sed
fi

# Install sdkman if not installed
if [ ! -d "${SDKMAN_DIR}" ]; then
    curl -sSL "https://get.sdkman.io?rcupdate=false" | bash
    chown -R "${USERNAME}" "${SDKMAN_DIR}"
    # Add sourcing of sdkman into bashrc/zshrc files (unless disabled)
    updaterc "export SDKMAN_DIR=${SDKMAN_DIR}\nsource \${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

# Install Maven
su ${USERNAME} -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install maven ${MAVEN_VERSION} && sdk flush archives && sdk flush temp"
updaterc "export M2=\$HOME/.m2"
echo "Done!"