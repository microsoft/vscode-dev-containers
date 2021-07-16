#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/python.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./python-debian.sh [Python Version] [Python intall path] [PIPX_HOME] [non-root user] [Update rc files flag] [install tools]

PYTHON_VERSION=${1:-"latest"}
PYTHON_INSTALL_PATH=${2:-"/usr/local/python"}
export PIPX_HOME=${3:-"/usr/local/py-utils"}
USERNAME=${4:-"automatic"}
UPDATE_RC=${5:-"true"}
INSTALL_PYTHON_TOOLS=${6:-"true"}

PYTHON_SOURCE_GPG_KEYS="64E628F8D684696D B26995E310250568 2D347EA6AA65421D FB9921286F5E1540"
GPG_KEY_SERVERS="keyserver hkp://keyserver.ubuntu.com:80
keyserver hkps://keys.openpgp.org
keyserver hkp://keyserver.pgp.com"

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

function getCommonSetting() {
    if [ "${COMMON_SETTINGS_LOADED}" != "true" ]; then
        curl -sL --fail-with-body "https://aka.ms/vscode-dev-containers/script-library/settings.env" 2>/dev/null -o /tmp/vsdc-settings.env || echo "Could not download settings file. Skipping."
        COMMON_SETTINGS_LOADED=true
    fi
    local multi_line=""
    if [ "$2" = "true" ]; then multi_line="-z"; fi
    if [ -f "/tmp/vsdc-settings.env" ]; then
        if [ ! -z "$1" ]; then declare -g $1="$(grep ${multi_line} -oP "${$1}=\"?\K[^\"]+" /tmp/vsdc-settings.env | tr -d '\0')"; fi
    fi
}

function importGPGKeys() {
    getCommonSetting $1
    local keys=${!1}
    getCommonSetting GPG_KEY_SERVERS true

    # Use a temporary locaiton for gpg keys to avoid polluting image
    export GNUPGHOME="/tmp/tmp-gnupg"
    mkdir -p ${GNUPGHOME}
    chmod 700 ${GNUPGHOME}
    echo -e "disable-ipv6\n${GPG_KEY_SERVERS}" > ${GNUPGHOME}/dirmngr.conf
    # GPG key download sometimes fails for some reason and retrying fixes it.
    local retry_count=0
    local gpg_ok="false"
    set +e
    until [ "${gpg_ok}" = "true" ] || [ "${retry_count}" -eq "5" ]; 
    do
        echo "(*) Downloading GPG key..."
        ( echo "${keys}" | xargs -n 1 gpg --recv-keys) 2>&1 && gpg_ok="true"
        if [ "${gpg_ok}" != "true" ]; then
            echo "(*) Failed getting key, retring in 10s..."
            (( retry_count++ ))
            sleep 10s
        fi
    done
    set -e
    if [ "${gpg_ok}" = "false" ]; then
        echo "(!) Failed to install rvm."
        exit 1
    fi
}

# Function to run apt-get if needed
apt-get-update-if-needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Install python from source if needed
if [ "${PYTHON_VERSION}" != "none" ]; then
    if [ -d "${PYTHON_INSTALL_PATH}" ]; then
        echo "Path ${PYTHON_INSTALL_PATH} already exists. Remove this existing path or select a different one."
        exit 1
    else
        echo "Building Python ${PYTHON_VERSION} from source..."
        # Install prereqs if missing
        PREREQ_PKGS="curl ca-certificates tar make build-essential libssl-dev zlib1g-dev \
                    wget libbz2-dev libreadline-dev libxml2-dev xz-utils tk-dev gnupg2 \
                    libxmlsec1-dev libsqlite3-dev libffi-dev liblzma-dev llvm dirmngr"
        if ! dpkg -s ${PREREQ_PKGS} > /dev/null 2>&1; then
            apt-get-apt-get-update-if-needed
            apt-get -y install --no-install-recommends ${PREREQ_PKGS}
        fi
        if ! type git > /dev/null 2>&1; then
            apt-get-apt-get-update-if-needed
            apt-get -y install --no-install-recommends git
        fi

        # Figure out correct version of a three part version number is not passed
        PYTHON_VERSION_LIST="$(git ls-remote --tags https://github.com/python/cpython | grep -oP 'tags/v\K[0-9]+\.[0-9]+\.[0-9]+$' | sort -rV)"
        if [ "$(echo "${PYTHON_VESRION}" | grep -o '\.' | wc -l)" != "2" ]; then
            if [ "${PYTHON_VERSION}" = "latest" ] || [ "${PYTHON_VERSION}" = "current" ] || [ "${PYTHON_VERSION}" = "lts" ]; then
                PYTHON_VERSION="$(echo "${PYTHON_VERSION_LIST}" | head -n 1)"
            else 
                PYTHON_VERSION="$(echo "${PYTHON_VERSION_LIST}" | grep -m1 "${PYTHON_VESION}")"
            fi
        fi
        if ! echo "${PYTHON_VERSION_LIST}" | grep "^${PYTHON_VERSION}$" > /dev/null 2>&1; then
            echo "Invalid Python version ${PYTHON_VERSION}"
            exit 1
        fi
        echo "Target Python version: ${PYTHON_VERSION}"

        # Get signing keys
        importGPGKeys PYTHON_SOURCE_GPG_KEYS

        # Download and build from src
        mkdir -p /tmp/python-src "${PYTHON_INSTALL_PATH}"
        cd /tmp/python-src
        TGZ_FILENAME="Python-${PYTHON_VERSION}.tgz"
        TGZ_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/${TGZ_FILENAME}"
        echo "Downloading ${TGZ_FILENAME}..."
        curl -sSL -o "/tmp/python-src/${TGZ_FILENAME}" "${TGZ_URL}"
        echo "Downloading ${TGZ_FILENAME}.asc..."
        curl -sSL -o "/tmp/python-src/${TGZ_FILENAME}.asc" "${TGZ_URL}.asc"
        gpg --verify "${TGZ_FILENAME}.asc"
        tar -xzf "/tmp/python-src/${TGZ_FILENAME}" -C "/tmp/python-src" --strip-components=1
        ./configure --prefix="${PYTHON_INSTALL_PATH}" --enable-optimizations --with-ensurepip=install
        make -j 8
        make install
        cd /tmp
        rm -rf /tmp/python-src ${GNUPGHOME} /tmp/vscdc-settings.env
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
