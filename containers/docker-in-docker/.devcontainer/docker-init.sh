#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

set -e

# Favor environment variables - if they are not set, use args
ENABLE_NONROOT_DOCKER=${DOCKER_INIT_ENABLE_NONROOT:-"$1"} # true/false
SOURCE_SOCKET=${DOCKER_INIT_SOURCE_SOCKET:-"$2"} # /var/run/docker-host.sock
TARGET_SOCKET=${DOCKER_INIT_TARGET_SOCKET:-"$3"} # /var/run/docker.sock
NONROOT_USER=${DOCKER_INIT_NONROOT_USER:-"$4"} # vscode
if [ -z "${DOCKER_INIT_ENABLE_NONROOT}" ]; then shift 4; fi

SOCAT_LOG_PATH=/tmp/vscr-dind-socat.log

echo "(*) Ensuring ${NONROOT_USER} has access to ${SOURCE_SOCKET} via ${TARGET_SOCKET}"

# Wrapper function to only use sudo if not already root
sudoIf()
{
    if [ "$(id -u)" -ne 0 ]; then
        sudo $@
    else
        $@
    fi
}

# If enabled, use socat to forward the docker socket to another unix socket 
# so that we can set permissions on it without affecting the host.
if [ "${ENABLE_NONROOT_DOCKER}" = "true" ] && [ "${SOURCE_SOCKET}" != "${TARGET_SOCKET}" ] && [ "${NONROOT_USER}" != "root" ] && [ "${NONROOT_USER}" != "0" ]; then
    echo "(*) Enabling proxy..."
    date >> ${SOCAT_LOG_PATH}
    echo "Proxying ${SOURCE_SOCKET} to ${TARGET_SOCKET} for ${NONROOT_USER}" >> ${SOCAT_LOG_PATH}
    sudoIf rm -rf ${TARGET_SOCKET}
    ((sudoIf socat UNIX-LISTEN:${TARGET_SOCKET},fork,mode=660,user=${NONROOT_USER} UNIX-CONNECT:${SOURCE_SOCKET}) 2>&1 >> ${SOCAT_LOG_PATH}) & > /dev/null
fi

echo "(*) Success"

# Execute whatever commands were passed in (if any). This allows us 
# to set this  script to ENTRYPOINT while still executing the default CMD.
$@