#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/git-from-src.md
#
# Syntax: ./git-from-src-debian.sh [version]

GIT_VERSION=${1:-"latest"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ "${GIT_VERSION}" = "latest" ] || [ "${GIT_VERSION}" = "lts" ] || [ "${GIT_VERSION}" = "current" ]; then
    RECENT_TAGS=$(curl -sSL -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/git/git/tags")
    GIT_VERSION=$(echo ${RECENT_TAGS} | grep -oE 'name":\s*"v[0-9]+\.[0-9]+\.[0-9]+"' | head -n 1 | sed 's/^name":\s*"v\(.*\)"$/\1/')
fi

export DEBIAN_FRONTEND=noninteractive

# Install required packages to build if missing
if ! dpkg -s build-essential curl ca-certificates tar gettext libssl-dev zlib1g-dev libexpat1-dev> /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends build-essential curl ca-certificates tar gettext libssl-dev zlib1g-dev libcurl?-openssl-dev libexpat1-dev
fi

echo "Downloading source for ${GIT_VERSION}..."
curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz | tar -xzC /tmp 2>&1
echo "Building..."
cd /tmp/git-${GIT_VERSION}
make -s prefix=/usr/local all && make -s prefix=/usr/local install 2>&1
rm -rf /tmp/git-${GIT_VERSION}
echo "Done!"
