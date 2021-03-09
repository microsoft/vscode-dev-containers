#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/python.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./python-debian.sh [Python Version] [Python intall path] [PIPX_HOME] [non-root user] [Update rc files flag] [install tools]

PYTHON_VERSION=${1:-"3.8.3"}
PYTHON_INSTALL_PATH=${2:-"/usr/local/python${PYTHON_VERSION}"}
export PIPX_HOME=${3:-"/usr/local/py-utils"}
USERNAME=${4:-"automatic"}
UPDATE_RC=${5:-"true"}
INSTALL_PYTHON_TOOLS=${6:-"true"}

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

function updaterc() {
    if [ "${UPDATE_RC}" = "true" ]; then
        echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
        echo -e "$1" >> /etc/bash.bashrc
        if [ -f "/etc/zsh/zshrc" ]; then
            echo -e "$1" >> /etc/zsh/zshrc
        fi
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Install python from source if needed
if [ "${PYTHON_VERSION}" != "none" ]; then

    if [ -d "${PYTHON_INSTALL_PATH}" ]; then
        echo "Path ${PYTHON_INSTALL_PATH} already exists. Assuming Python already installed."
    else
        echo "Building Python ${PYTHON_VERSION} from source..."
        # Install prereqs if missing
        PREREQ_PKGS="curl ca-certificates tar make build-essential libffi-dev \
            libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
            libncurses5-dev libncursesw5-dev xz-utils tk-dev"
        if ! dpkg -s ${PREREQ_PKGS} > /dev/null 2>&1; then
            if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
                apt-get update
            fi
            apt-get -y install --no-install-recommends ${PREREQ_PKGS}
        fi

        # Download and build from src
        mkdir -p /tmp/python-src "${PYTHON_INSTALL_PATH}"
        cd /tmp/python-src
        curl -sSL -o /tmp/python-dl.tgz "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
        tar -xzf /tmp/python-dl.tgz -C "/tmp/python-src" --strip-components=1
        ./configure --prefix="${PYTHON_INSTALL_PATH}" --enable-optimizations --with-ensurepip=install
        make -j 8
        make install
        rm -rf /tmp/python-dl.tgz /tmp/python-src
        cd /tmp
        chown -R ${USERNAME} "${PYTHON_INSTALL_PATH}"
        ln -s ${PYTHON_INSTALL_PATH}/bin/python3 ${PYTHON_INSTALL_PATH}/bin/python
        ln -s ${PYTHON_INSTALL_PATH}/bin/pip3 ${PYTHON_INSTALL_PATH}/bin/pip
        ln -s ${PYTHON_INSTALL_PATH}/bin/idle3 ${PYTHON_INSTALL_PATH}/bin/idle
        ln -s ${PYTHON_INSTALL_PATH}/bin/pydoc3 ${PYTHON_INSTALL_PATH}/bin/pydoc
        ln -s ${PYTHON_INSTALL_PATH}/bin/python3-config ${PYTHON_INSTALL_PATH}/bin/python-config
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
export PATH=${PYTHON_INSTALL_PATH}/bin:${PIPX_BIN_DIR}:${PATH}

# Update pip
echo "Updating pip..."
python3 -m pip install --no-cache-dir --upgrade pip

# Create pipx group, dir, and set sticky bit
if ! cat /etc/group | grep -e "^pipx:" > /dev/null 2>&1; then
    groupadd -r pipx
fi
usermod -a -G pipx ${USERNAME}
umask 0002
mkdir -p ${PIPX_BIN_DIR}
chown :pipx ${PIPX_HOME} ${PIPX_BIN_DIR}
chmod g+s ${PIPX_HOME} ${PIPX_BIN_DIR}

# Install tools
echo "Installing Python tools..."
export PYTHONUSERBASE=/tmp/pip-tmp
export PIP_CACHE_DIR=/tmp/pip-tmp/cache
pip3 install --disable-pip-version-check --no-warn-script-location  --no-cache-dir --user pipx
/tmp/pip-tmp/bin/pipx install --pip-args=--no-cache-dir pipx
echo "${DEFAULT_UTILS}" | xargs -n 1 /tmp/pip-tmp/bin/pipx install --system-site-packages --pip-args '--no-cache-dir --force-reinstall'
rm -rf /tmp/pip-tmp

updaterc "$(cat << EOF
export PIPX_HOME="${PIPX_HOME}"
export PIPX_BIN_DIR="${PIPX_BIN_DIR}"
if [[ "\${PATH}" != *"\${PIPX_BIN_DIR}"* ]]; then export PATH="\${PATH}:\${PIPX_BIN_DIR}"; fi
EOF
)"
