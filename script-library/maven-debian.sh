#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Syntax: ./maven-debian.sh <maven version> [maven home]  [non-root user] [maven SHA 512]

MAVEN_VERSION=$1
MAVEN_HOME=${2:-"/usr/local/share/maven"}
USERNAME=${3:-"vscode"}
MAVEN_DOWNLOAD_SHA=${4:-"no-check"}

set -e

if [ -d "${MAVEN_HOME}" ]; then
    echo "Maven already installed."
    exit 0
fi

if [ -z "$1" ]; then
    echo -e "Required argument missing.\n\nmaven-debian.sh <maven version> [maven home]  [non-root user] [maven SHA 512]"
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

# Creat folder, add maven settings
mkdir -p ${MAVEN_HOME} ${MAVEN_HOME}/ref
tee ${MAVEN_HOME}/ref/maven-settings.xml > /dev/null \
<< EOF 
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <localRepository>${MAVEN_HOME}/ref/repository</localRepository>
</settings>
EOF
chown -R ${USERNAME}:root ${MAVEN_HOME}

# Install Maven
echo "Downloading Maven..."
suIf "$(cat \
<< EOF
    curl -fsSL -o /tmp/maven.tar.gz https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
    ([ "${MAVEN_DOWNLOAD_SHA}" = "dev-mode" ] || echo "${MAVEN_DOWNLOAD_SHA} */tmp/maven.tar.gz" | sha512sum -c - )
    tar -xzf /tmp/maven.tar.gz -C ${MAVEN_HOME} --strip-components=1
    rm -f /tmp/maven.tar.gz
EOF
)"
ln -s ${MAVEN_HOME}/bin/mvn /usr/local/bin/mvn
echo "Done."
