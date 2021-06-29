#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# ** This script is community supported **
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/homebrew.md
# Maintainer: @andreiborisov
#
# Syntax: ./homebrew-debian.sh [non-root user] [add Homebrew binaries to PATH] [whether to use shallow clone] [where to install Homebrew]

USERNAME=${1:-"automatic"}
UPDATE_RC=${2:-"true"}
USE_SHALLOW_CLONE=${3:-"false"}
BREW_PREFIX=${4:-"/home/linuxbrew/.linuxbrew"}

set -e

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
        echo -e "$1" >> /etc/bash.bashrc
        if [ -f "/etc/zsh/zshrc" ]; then
            echo -e "$1" >> /etc/zsh/zshrc
        fi
    fi
}

function updatefishconfig() {
    if [ "${UPDATE_RC}" = "true" ]; then
        echo "Updating /etc/fish/config.fish..."
        if [ -f "/etc/fish/config.fish" ]; then
             echo -e "$1" >> /etc/fish/config.fish
         fi
    fi
}

export DEBIAN_FRONTEND=noninteractive

ARCHITECTURE="$(uname -m)"
if [ "${ARCHITECTURE}" != "amd64" ] && [ "${ARCHITECTURE}" != "x86_64" ]; then
    echo "(!) Architecture $ARCHITECTURE unsupported"
    exit 1
fi

# Install dependencies if missing
if ! dpkg -s \
    bzip2 \
    ca-certificates \
    curl \
    file \
    fonts-dejavu-core \
    g++ \
    git \
    less \
    libz-dev \
    locales \
    make \
    netbase \
    openssh-client \
    patch \
    sudo \
    tzdata \
    uuid-runtime \
    > /dev/null 2>&1; then
        if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get -y install --no-install-recommends \
            bzip2 \
            ca-certificates \
            curl \
            file \
            fonts-dejavu-core \
            g++ \
            git \
            less \
            libz-dev \
            locales \
            make \
            netbase \
            openssh-client \
            patch \
            sudo \
            tzdata \
            uuid-runtime
fi

# Install Homebrew
mkdir -p "${BREW_PREFIX}"
if [ "${USE_SHALLOW_CLONE}" = "false" ]; then
    echo "Installing Homebrew..."
    git clone https://github.com/Homebrew/brew "${BREW_PREFIX}/Homebrew"
    mkdir -p "${BREW_PREFIX}/Homebrew/Library/Taps/homebrew"
    git clone https://github.com/Homebrew/linuxbrew-core "${BREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-core"
else
    echo "Installing Homebrew with shallow clone..."
    git clone --depth 1 https://github.com/Homebrew/brew "${BREW_PREFIX}/Homebrew"
    mkdir -p "${BREW_PREFIX}/Homebrew/Library/Taps/homebrew"
    git clone --depth 1 https://github.com/Homebrew/linuxbrew-core "${BREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-core"
    # Disable automatic updates as they are not allowed with shallow clone installation
    updaterc "export HOMEBREW_NO_AUTO_UPDATE=1"
    updatefishconfig "set -gx HOMEBREW_NO_AUTO_UPDATE 1"
fi
"${BREW_PREFIX}/Homebrew/bin/brew" config
mkdir "${BREW_PREFIX}/bin"
ln -s "${BREW_PREFIX}/Homebrew/bin/brew" "${BREW_PREFIX}/bin"
chown -R ${USERNAME} "${BREW_PREFIX}"

# Add Homebrew binaries into PATH in bashrc/zshrc/config.fish files (unless disabled)
updaterc "$(cat << EOF
if [[ "\${PATH}" != *"${BREW_PREFIX}/bin"* ]]; then export PATH="${BREW_PREFIX}/bin:\${PATH}"; fi
if [[ "\${PATH}" != *"${BREW_PREFIX}/sbin"* ]]; then export PATH="${BREW_PREFIX}/sbin:\${PATH}"; fi
EOF
)"
updatefishconfig "fish_add_path ${BREW_PREFIX}/bin ${BREW_PREFIX}/sbin"

echo "Done!"
