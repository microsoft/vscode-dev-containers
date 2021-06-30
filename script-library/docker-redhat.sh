#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# ** This script is community supported **
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/docker.md
# Maintainer: @smankoo
#
# Syntax: ./docker-redhat.sh [enable non-root docker socket access flag] [source socket] [target socket] [non-root user]

ENABLE_NONROOT_DOCKER=${1:-"true"}
SOURCE_SOCKET=${2:-"/var/run/docker-host.sock"}
TARGET_SOCKET=${3:-"/var/run/docker.sock"}
USERNAME=${4:-"automatic"}

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

# Install Prerequisites
if yum list deltarpm > /dev/null 2>&1; then
    yum -y install deltarpm
fi
yum -y install ca-certificates curl gnupg2 dnf net-tools dialog git openssh-clients curl less procps 

# Try to load os-release
. /etc/os-release 2>/dev/null

# If unable to load OS Name and Verstion from os-release, install lsb_release
if [ $? -ne 0 ] || [ "${NAME}" = "" ] || [ "${VERSION_ID}" = "" ]; then

    yum -y install redhat-lsb-core

    OSNAME=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    RHEL_COMPAT_VER=${VERSION_ID:-`lsb_release -rs | cut -d. -f1`}

else
    OSNAME=`echo $NAME | cut -d" " -f1 | tr '[:upper:]' '[:lower:]'`
    if [ "${OSNAME}" = "amazon" ]; then
        if [ "${VERSION_ID}" = "2" ]; then
            RHEL_COMPAT_VER=7
        else
            echo "Incompatible Operative System. Exiting..."
            exit
        fi
    else
        RHEL_COMPAT_VER=$VERSION_ID
    fi
fi

curl -fsSL https://download.docker.com/linux/${OSNAME}/gpg > /tmp/docker.gpg && \
rpm --import /tmp/docker.gpg

yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-${RHEL_COMPAT_VER}.noarch.rpm
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum -y update
yum -y install docker-ce-cli

# Install Docker Compose
LATEST_COMPOSE_VERSION=$(basename "$(curl -fsSL -o /dev/null -w "%{url_effective}" https://github.com/docker/compose/releases/latest)")
curl -fsSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# By default, make the source and target sockets the same
if [ "${SOURCE_SOCKET}" != "${TARGET_SOCKET}" ]; then
    touch "${SOURCE_SOCKET}"
    ln -s "${SOURCE_SOCKET}" "${TARGET_SOCKET}"
    chown -h "${USERNAME}" "${TARGET_SOCKET}"
fi

# If enabling non-root access, setup socat
if [ "${ENABLE_NONROOT_DOCKER}" = "true" ]; then
    yum -y install socat
    tee /usr/local/share/docker-init.sh > /dev/null \
<< EOF 
#!/usr/bin/env bash
set -e

SOCAT_PATH_BASE=/tmp/vscr-dind-socat
SOCAT_LOG=\${SOCAT_PATH_BASE}.log
SOCAT_PID=\${SOCAT_PATH_BASE}.pid

# Wrapper function to only use sudo if not already root
sudoIf()
{
    if [ "\$(id -u)" -ne 0 ]; then
        sudo "\$@"
    else
        "\$@"
    fi
}

# Log messages
log()
{
    echo -e "[\$(date)] \$@" | sudoIf tee -a \${SOCAT_LOG} > /dev/null
}

echo -e "\n** \$(date) **" | sudoIf tee -a \${SOCAT_LOG} > /dev/null
log "Ensuring ${USERNAME} has access to ${SOURCE_SOCKET} via ${TARGET_SOCKET}"

# If enabled, try to add a docker group with the right GID. If the group is root, 
# fall back on using socat to forward the docker socket to another unix socket so 
# that we can set permissions on it without affecting the host.
if [ "${ENABLE_NONROOT_DOCKER}" = "true" ] && [ "${SOURCE_SOCKET}" != "${TARGET_SOCKET}" ] && [ "${USERNAME}" != "root" ] && [ "${USERNAME}" != "0" ]; then
    SOCKET_GID=\$(stat -c '%g' ${SOURCE_SOCKET})
    if [ "\${SOCKET_GID}" != "0" ]; then
        log "Adding user to group with GID \${SOCKET_GID}."
        if [ "\$(cat /etc/group | grep :\${SOCKET_GID}:)" = "" ]; then
            sudoIf groupadd --gid \${SOCKET_GID} docker-host
        fi
        # Add user to group if not already in it
        if [ "\$(id ${USERNAME} | grep -E 'groups=.+\${SOCKET_GID}\(')" = "" ]; then
            sudoIf usermod -aG \${SOCKET_GID} ${USERNAME}
        fi
    else
        # Enable proxy if not already running
        if [ ! -f "\${SOCAT_PID}" ] || ! ps -p \$(cat \${SOCAT_PID}) > /dev/null; then
            log "Enabling socket proxy."
            log "Proxying ${SOURCE_SOCKET} to ${TARGET_SOCKET} for vscode"
            sudoIf rm -rf ${TARGET_SOCKET}
            (sudoIf socat UNIX-LISTEN:${TARGET_SOCKET},fork,mode=660,user=${USERNAME} UNIX-CONNECT:${SOURCE_SOCKET} 2>&1 | sudoIf tee -a \${SOCAT_LOG} > /dev/null & echo "\$!" | sudoIf tee \${SOCAT_PID} > /dev/null)
        else
            log "Socket proxy already running."
        fi
    fi
    log "Success"
fi

# Execute whatever commands were passed in (if any). This allows us 
# to set this script to ENTRYPOINT while still executing the default CMD.
set +e
exec "\$@"
EOF
else 
    echo '/usr/bin/env bash -c "\$@"' > /usr/local/share/docker-init.sh
fi
chmod +x /usr/local/share/docker-init.sh
echo "Done!"
