#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Syntax: ./java-debian.sh [JDK version] [SDKMAN_DIR] [non-root user] [Add to rc files flag]

JAVA_VERSION=${1:-"lts"}
export SDKMAN_DIR=${2:-"/usr/local/sdkman"}
USERNAME=${3:-"vscode"}
UPDATE_RC=${4:-"true"}

set -e

# Blank will install latest AdoptOpenJDK version
if [ "${JAVA_VERSION}" = "lts" ]; then
    JAVA_VERSION=""
fi

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run a root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Treat a user name of "none" or non-existant user as root
if [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

function updaterc() {
    if [ "${UPDATE_RC}" = "true" ]; then
        local -r sh_name="$1"
        local -r rc_snippet="$2"
        local -r profile_snippet=". /etc/profile"
        if ! grep -q "${profile_snippet}" /etc/bash.bashrc; then
            echo -e "${profile_snippet}\n$(cat /etc/bash.bashrc)" > /etc/bash.bashrc
        fi
        if ! grep -q "${profile_snippet}" /etc/zsh/zshrc; then
            echo -e "${profile_snippet}\n$(cat /etc/zsh/zshrc)" > /etc/zsh/zshrc
        fi
        echo -e "${rc_snippet}" >> "/etc/profile.d/${sh_name}.sh"
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
    updaterc sdkman "export SDKMAN_DIR=${SDKMAN_DIR}\n. \${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

if [ "${JAVA_VERSION}" != "none" ]; then
    su ${USERNAME} -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install java ${JAVA_VERSION} && sdk flush archives && sdk flush temp"
fi

echo "Done!"