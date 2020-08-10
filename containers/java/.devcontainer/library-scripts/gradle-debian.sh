#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Syntax: ./gradle-debian.sh <gradle version> [gradle home] [non-root-user] [gradle SHA 256]

GRADLE_VERSION=$1
GRADLE_HOME=${2:-"/usr/local/share/gradle"}
USERNAME=${3:-"vscode"}
GRADLE_DOWNLOAD_SHA=${4:-"no-check"}

set -e

if [ -d "${GRADLE_HOME}" ]; then
    echo "Gradle already installed."
    exit 0
fi

if [ -z "$1" ]; then
    echo -e "Required argument missing.\n\ngradle-debian.sh <gradle version> [gradle home] [non-root-user] [gradle SHA 256]"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run a root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Treat a user name of "none" or non-existant user as root
if [ "${USERNAME}" = "none" ] && ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

# Install curl, apt-get dependencies if missing
if ! type curl > /dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends ca-certificates curl gnupg2
fi

# Function to su if user exists and is not root
suIf() {
    if [ "${USERNAME}" != "root" ]; then
        su ${USERNAME} -c "$@"
    else
        "$@"
    fi
}

# Install Gradle
echo "Downloading Gradle..."
suIf "$(cat \
<< EOF
    mkdir -p /tmp/downloads
    curl -sSL --output /tmp/downloads/archive-gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
    ([ "${GRADLE_DOWNLOAD_SHA}" = "no-check" ] || echo "${GRADLE_DOWNLOAD_SHA} */tmp/downloads/archive-gradle.zip" | sha256sum --check - )
    unzip -q /tmp/downloads/archive-gradle.zip -d /tmp/downloads/
EOF
)"
mv -f /tmp/downloads/gradle* ${GRADLE_HOME}
chown ${USERNAME}:root ${GRADLE_HOME}
ln -s ${GRADLE_HOME}/bin/gradle /usr/local/bin/gradle
rm -rf /tmp/downloads
echo "Done."


