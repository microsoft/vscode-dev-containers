#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/go.md
#
# Syntax: ./mit-scheme-debian.sh [Scheme version] [TARGET SCHEME PATH] [non-root user]

TARGET_SCHEME_VERSION=${1:-"11.1"}
TARGET_SCHEME_PATH=${2:-"/usr/local/mit-scheme"}
USERNAME=${3:-"automatic"}

set -e

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


export DEBIAN_FRONTEND=noninteractive

# Install gcc make m4 libncurses-dev
# More detail https://www.gnu.org/software/mit-scheme/documentation/stable/mit-scheme-user/Unix-Installation.html

if ! dpkg -s gcc make m4 libncurses-dev > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends gcc make m4 libncurses-dev
fi

# Install MIT-Scheme
# More detail https://www.gnu.org/software/mit-scheme/documentation/stable/mit-scheme-user/Unix-Installation.html
SCHEME_INSTALL_SCRIPT="$(cat <<EOF
    set -e

    # Wrapper function to only use sudo if not already root
    sudoIf()
    {
        if [ "\$(id -u)" -ne 0 ]; then
            sudo "\$@"
        else
            "\$@"
        fi
    }

    echo "Downloading MIT-Scheme ${TARGET_SCHEME_VERSION}..."
    curl -sSL -o /tmp/mit-scheme.tar.gz "https://ftp.gnu.org/gnu/mit-scheme/stable.pkg/${TARGET_SCHEME_VERSION}/mit-scheme-${TARGET_SCHEME_VERSION}-x86-64.tar.gz"
    echo "Extracting MIT-Scheme ${TARGET_SCHEME_VERSION}..."
    tar -xzf /tmp/mit-scheme.tar.gz -C "${TARGET_SCHEME_PATH}" --strip-components=1
    cd "${TARGET_SCHEME_PATH}"/src
    
    # Check the normal arguments for the scripts if there have, more detail 
    sudoIf ./configure
    
    # Build the software
    sudoIf make

    # Install the software
    sudoIf make install

    # Delete the source directory
    sudoIf rm -rf "${TARGET_SCHEME_PATH}"
EOF
)"
if [ "${TARGET_SCHEME_VERSION}" != "none" ] > /dev/null 2>&1; then
    mkdir -p "${TARGET_SCHEME_PATH}"
    chmod +x "${TARGET_SCHEME_PATH}"
    chown -R ${USERNAME}:root "${TARGET_SCHEME_PATH}"
    su ${USERNAME} -c "${SCHEME_INSTALL_SCRIPT}"
else
    echo "mit-scheme already installed. Skipping."
fi

echo "Done!"