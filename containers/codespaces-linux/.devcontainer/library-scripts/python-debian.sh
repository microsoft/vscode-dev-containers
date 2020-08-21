#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Syntax: ./python-debian.sh [Python Version] [Python intall path] [PIPX_HOME] [non-root user] [Update rc files flag] [install tools]

PYTHON_VERSION=${1:-"3.8.3"}
PYTHON_INSTALL_PATH=${2:-"/usr/local/python"}
export PIPX_HOME=${3:-"/usr/local/py-utils"}
USERNAME=${4:-"vscode"}
UPDATE_RC=${5:-"true"}
INSTALL_PYTHON_TOOLS=${6:-"true"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run a root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Treat a user name of "none" or non-existant user as root
if [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

function updaterc() {
    if [ "${UPDATE_RC}" = "true" ]; then
        RC_SNIPPET="$1"
        echo -e ${RC_SNIPPET} | tee -a /root/.bashrc /root/.zshrc >> /etc/skel/.bashrc 
        if [ "${USERNAME}" != "root" ]; then
            echo -e ${RC_SNIPPET} | tee -a /home/${USERNAME}/.bashrc >> /home/${USERNAME}/.zshrc 
        fi
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Install curl, tar if missing
if ! dpkg -s curl ca-certificates tar > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends curl ca-certificates tar
fi

PYTHON_INSTALL_SCRIPT="$(cat << EOF
    set -e
    curl -sSL -o /tmp/python-dl.tgz "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
    tar -xzf /tmp/python-dl.tgz -C ${PYTHON_INSTALL_PATH} --strip-components=1
    rm -f /tmp/python-dl.tgz
EOF
)"

if [ "${PYTHON_VERSION}" != "none" ]; then
    if [ -d "${PYTHON_INSTALL_PATH}" ]; then
        echo "Path ${PYTHON_INSTALL_PATH} already exists. Assuming Python already installed."
    else
        mkdir -p "${PYTHON_INSTALL_PATH}"
        chown ${USERNAME} "${PYTHON_INSTALL_PATH}"
        su ${USERNAME} -c "${PYTHON_INSTALL_SCRIPT}"
        updaterc "export PATH=${PYTHON_INSTALL_PATH}/bin:\${PATH}"
    fi
fi

# If not installing python tools, exit
if [ "${INSTALL_PYTHON_TOOLS}" != "true" ]; then
    echo "Done!"
    exit 0;
fi

DEFAULT_UTILS="\
    pylint \
    flake8 \
    autopep8 \
    black \
    yapf \
    mypy \
    pydocstyle \
    pycodestyle \
    bandit \
    pipenv \
    virtualenv"

export PIPX_BIN_DIR=${PIPX_HOME}/bin
mkdir -p ${PIPX_BIN_DIR}
chown -R ${USERNAME} ${PIPX_HOME} ${PIPX_BIN_DIR}
su ${USERNAME} -c "$(cat << EOF
    set -e
    export PATH=${PYTHON_INSTALL_PATH}/bin:${PIPX_BIN_DIR}:\${PATH}
    export PIPX_HOME=${PIPX_HOME}
    export PIPX_BIN_DIR=${PIPX_BIN_DIR}
    export PYTHONUSERBASE=/tmp/pip-tmp
    pip3 install --disable-pip-version-check --no-warn-script-location --no-cache-dir --user pipx
    /tmp/pip-tmp/bin/pipx install --pip-args=--no-cache-dir pipx
    echo "${DEFAULT_UTILS}" | xargs -n 1 /tmp/pip-tmp/bin/pipx install --system-site-packages --pip-args=--no-cache-dir --pip-args=--force-reinstall
    chown -R ${USERNAME} ${PIPX_HOME}
    rm -rf /tmp/pip-tmp
EOF
)"
updaterc "export PIPX_HOME=${PIPX_HOME}\nexport PIPX_BIN_DIR=${PIPX_BIN_DIR}\nexport PATH=${PATH}:${PYTHON_INSTALL_PATH}/bin\${PIPX_BIN_DIR}"
