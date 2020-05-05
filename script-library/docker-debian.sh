#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Syntax: ./docker-debian.sh <enable non-root docker socket access flag> <source socket> <target socket> <non-root user>

set -e

ENABLE_NONROOT_DOCKER=${1:-"true"}
SOURCE_SOCKET=${2:-"/var/run/docker-host.sock"}
TARGET_SOCKET=${3:-"/var/run/docker.sock"}
NONROOT_USER=${4:-"vscode"}

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run a root. Use sudo or set "USER root" before running the script.'
    exit 1
fi

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Install Docker CLI
apt-get -y install  --no-install-recommends apt-transport-https ca-certificates curl gnupg2 lsb-release
curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT)
echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
apt-get update
apt-get -y install --no-install-recommends docker-ce-cli

# Install Docker Compose
LATEST_COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -o -P '(?<="tag_name": ").+(?=")')
curl -sSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose \

# By default, make the source and target sockets the same
if [ "${SOURCE_SOCKET}" != "${TARGET_SOCKET}" ]; then
    touch "${SOURCE_SOCKET}"
    ln -s "${SOURCE_SOCKET}" "${TARGET_SOCKET}"
fi

# If enabling non-root access, setup socat
if [ "${ENABLE_NONROOT_DOCKER}" = "true" ]; then
    apt-get -y install socat
    tee /usr/local/share/docker-init.sh << EOF 
#!/bin/sh
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

set -e

echo "(*) Ensuring ${NONROOT_USER} has access to ${SOURCE_SOCKET} via ${TARGET_SOCKET}"

# Wrapper function to only use sudo if not already root
sudoIf()
{
    if [ "\$(id -u)" -ne 0 ]; then
        sudo \$@
    else
        \$@
    fi
}

SOCAT_LOG_PATH=/tmp/vscr-dind-socat.log

# If enabled, use socat to forward the docker socket to another unix socket 
# so that we can set permissions on it without affecting the host.
if [ "${ENABLE_NONROOT_DOCKER}" = "true" ] && [ "${SOURCE_SOCKET}" != "${TARGET_SOCKET}" ] && [ "${NONROOT_USER}" != "root" ] && [ "${NONROOT_USER}" != "0" ]; then
    echo "(*) Enabling proxy..."
    date >> \${SOCAT_LOG_PATH}
    echo "Proxying ${SOURCE_SOCKET} to ${TARGET_SOCKET} for ${NONROOT_USER}" >> \${SOCAT_LOG_PATH}
    sudoIf rm -rf ${TARGET_SOCKET}
    ((sudoIf socat UNIX-LISTEN:${TARGET_SOCKET},fork,mode=660,user=${NONROOT_USER} UNIX-CONNECT:${SOURCE_SOCKET}) 2>&1 >> \${SOCAT_LOG_PATH}) & > /dev/null
fi

echo "(*) Success"

# Execute whatever commands were passed in (if any). This allows us 
# to set this script to ENTRYPOINT while still executing the default CMD.
\$@
EOF
else 
    echo "#!/bin/sh\necho '(*) Skipping proxy setup'" > /usr/local/share/docker-init.sh
fi
chmod +x /usr/local/share/docker-init.sh

