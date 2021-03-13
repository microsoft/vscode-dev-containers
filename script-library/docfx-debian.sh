#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# ** This script is community supported **
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/docfx.md
# Maintainer: @JamieMagee
#
# Syntax: ./docfx-debian.sh [non-root user]

USERNAME=${1:-"automatic"}

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

# Install docfx
curl -sSL https://github.com/dotnet/docfx/releases/download/3.0.0-beta1.804%2B90e456a78d/docfx-linux-x64-3.0.0-beta1.804+90e456a78d.zip -o /tmp/docfx.zip
mkdir -p /opt/docfx
unzip /tmp/docfx.zip -d /opt/docfx
chown -R ${USERNAME}:${USERNAME} /opt/docfx
chmod +x /opt/docfx/docfx
ln -s /opt/docfx/docfx /usr/local/bin/docfx

# Cleanup
rm /tmp/docfx.zip
echo "Done!"
