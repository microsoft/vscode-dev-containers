#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Syntax: ./java-debian.sh [JDK major version] [JAVA_HOME] [non-root user] [Add JAVA_HOME to rc files flag]

export JAVA_VERSION=${1:-"11"}
export JAVA_HOME=${2:-"/opt/java/openjdk-${JAVA_VERSION}"}
USERNAME=${3:-"vscode"}
UPDATE_RC=${4:-"true"}

set -e

JDK_11_URI="https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.8%2B10/OpenJDK11U-jdk_x64_linux_11.0.8_10.tar.gz"
JDK_8_URI="https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u265-b01/OpenJDK8U-jdk_x64_linux_8u265b01.tar.gz"

JAVA_URI_VAR="JDK_${JAVA_VERSION}_URI"
JAVA_URI=${!JAVA_URI_VAR} 

if [ "${JAVA_URI}" = "" ]; then
    echo 'Only Java versions 8 and 11 are supported by this script.'
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run a root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Treat a user name of "none" or non-existant user as root
if [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

export DEBIAN_FRONTEND=noninteractive

# Install curl if missing
if ! dpkg -s curl ca-certificates > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends curl ca-certificates 
fi

# Install Java
if [ -d "${JAVA_HOME}" ]; then
    echo "${JAVA_HOME} already exists. Assuming Java is already installed."
    exit 0
fi

mkdir -p "${JAVA_HOME}"
chown "${USERNAME}" "${JAVA_HOME}"



su ${USERNAME} -c "$(cat << EOF
    set -e
    echo "Downloading JDK ${JAVA_VERSION}..."
    curl -fsSL -o /tmp/openjdk.tar.gz ${JAVA_URI}
    echo "Installing JDK ${JAVA_VERSION}..."
    tar -xzf /tmp/openjdk.tar.gz -C ${JAVA_HOME} --strip-components=1
    rm -f /tmp/openjdk.tar.gz
EOF
)"

# Add JAVA_HOME and bin directory into bashrc/zshrc files (unless disabled)
if [ "${UPDATE_RC}" = "true" ]; then
    RC_SNIPPET="export JAVA_HOME=\"${JAVA_HOME}\"\nexport PATH=\"\${JAVA_HOME}/bin:\${PATH}\""
    echo -e ${RC_SNIPPET} | tee -a /root/.bashrc /root/.zshrc >> /etc/skel/.bashrc 
    if [ "${USERNAME}" != "root" ]; then
        echo -e ${RC_SNIPPET} | tee -a /home/${USERNAME}/.bashrc /home/${USERNAME}/.zshrc 
    fi
    echo "Done!"
else
    echo "Done! Be sure to add ${JAVA_HOME}/bin to the PATH."
fi