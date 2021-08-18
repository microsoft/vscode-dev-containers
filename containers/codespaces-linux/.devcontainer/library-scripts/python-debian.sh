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
USE_PPA_IF_AVAILABLE=${7:-"true"}

DEADSNAKES_PPA_ARCHIVE_GPG_KEY="F23C5A6CF475977595C89F51BA6932366A755776"
PYTHON_SOURCE_GPG_KEYS="64E628F8D684696D B26995E310250568 2D347EA6AA65421D FB9921286F5E1540 3A5CA953F73C700D 04C367C218ADD4FF 0EDDC5F26A45C816 6AF053F07D9DC8D2 C9BE28DEE6DF025C 126EB563A74B06BF D9866941EA5BBD71 ED9D77D5"
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

updaterc() {
    if [ "${UPDATE_RC}" = "true" ]; then
        echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
        echo -e "$1" >> /etc/bash.bashrc
        if [ -f "/etc/zsh/zshrc" ]; then
            echo -e "$1" >> /etc/zsh/zshrc
        fi
    fi
}

# Get central common setting
get_common_setting() {
    if [ "${common_settings_file_loaded}" != "true" ]; then
        curl -sfL "https://aka.ms/vscode-dev-containers/script-library/settings.env" 2>/dev/null -o /tmp/vsdc-settings.env || echo "Could not download settings file. Skipping."
        common_settings_file_loaded=true
    fi
    if [ -f "/tmp/vsdc-settings.env" ]; then
        local multi_line=""
        if [ "$2" = "true" ]; then multi_line="-z"; fi
        local result="$(grep ${multi_line} -oP "$1=\"?\K[^\"]+" /tmp/vsdc-settings.env | tr -d '\0')"
        if [ ! -z "${result}" ]; then declare -g $1="${result}"; fi
    fi
    echo "$1=${!1}"
}

# Import the specified key in a variable name passed in as 
receive_gpg_keys() {
    get_common_setting $1
    local keys=${!1}
    get_common_setting GPG_KEY_SERVERS true
    local keyring_args=""
    if [ ! -z "$2" ]; then
        mkdir -p "$(dirname \"$2\")"
        keyring_args="--no-default-keyring --keyring $2"
    fi

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
        ( echo "${keys}" | xargs -n 1 gpg -q ${keyring_args} --recv-keys) 2>&1 && gpg_ok="true"
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

# Figure out correct version of a three part version number is not passed
find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    local prefix=${3:-"tags/v"}
    local separator=${4:-"."}
    local last_part_optional=${5:-"false"}    
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        local version_list="$(git ls-remote --tags ${repository} | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g ${variable_name}="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

# Function to run apt-get if needed
apt_get_update_if_needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get -y install --no-install-recommends "$@"
    fi
}

install_from_ppa() {
    local requested_version="python${PYTHON_VERSION}"
    echo "Using PPA to install Python..."
    check_packages apt-transport-https curl ca-certificates gnupg2
    receive_gpg_keys DEADSNAKES_PPA_ARCHIVE_GPG_KEY /usr/share/keyrings/deadsnakes-archive-keyring.gpg 
    echo -e "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/deadsnakes-archive-keyring.gpg] http://ppa.launchpad.net/deadsnakes/ppa/ubuntu ${VERSION_CODENAME} main\ndeb-src [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/deadsnakes-archive-keyring.gpg] http://ppa.launchpad.net/deadsnakes/ppa/ubuntu ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/deadsnakes-ppa.list
    apt-get update
    if [ "${PYTHON_VERSION}" = "latest" ] || [ "${PYTHON_VERSION}" = "current" ] || [ "${PYTHON_VERSION}" = "lts" ]; then
        requested_version="$(apt-cache search '^python3\.[0-9]$' | grep -oE '^python3\.[0-9]' | sort -rV | head -n 1)"
        echo "Using ${requested_version} in place of ${PYTHON_VERSION}."
    fi
    apt-get -y install ${requested_version}
    rm -rf /tmp/tmp-gnupg
    exit 0
}

install_from_source() {
    if [ -d "${PYTHON_INSTALL_PATH}" ]; then
        echo "Path ${PYTHON_INSTALL_PATH} already exists. Remove this existing path or select a different one."
        exit 1
    else
        echo "Building Python ${PYTHON_VERSION} from source..."
        # Install prereqs if missing
        check_packages curl ca-certificates tar make build-essential libssl-dev zlib1g-dev \
                    wget libbz2-dev libreadline-dev libxml2-dev xz-utils tk-dev gnupg2 \
                    libxmlsec1-dev libsqlite3-dev libffi-dev liblzma-dev llvm dirmngr
        if ! type git > /dev/null 2>&1; then
            apt_get_update_if_needed
            apt-get -y install --no-install-recommends git
        fi

        # Find version using soft match
        find_version_from_git_tags PYTHON_VERSION "https://github.com/python/cpython"

        # Download tgz of source
        mkdir -p /tmp/python-src "${PYTHON_INSTALL_PATH}"
        cd /tmp/python-src
        TGZ_FILENAME="Python-${PYTHON_VERSION}.tgz"
        TGZ_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/${TGZ_FILENAME}"
        echo "Downloading ${TGZ_FILENAME}..."
        curl -sSL -o "/tmp/python-src/${TGZ_FILENAME}" "${TGZ_URL}"

        # Verify signature
        if [ "${SKIP_SIGNATURE_CHECK}" != "true" ]; then
            receive_gpg_keys PYTHON_SOURCE_GPG_KEYS
            echo "Downloading ${TGZ_FILENAME}.asc..."
            curl -sSL -o "/tmp/python-src/${TGZ_FILENAME}.asc" "${TGZ_URL}.asc"
            gpg --verify "${TGZ_FILENAME}.asc"
        fi

        # Update min protocol for testing only - https://bugs.python.org/issue41561
        cp /etc/ssl/openssl.cnf /tmp/python-src/
        sed -i -E 's/MinProtocol[=\ ]+.*/MinProtocol = TLSv1.0/g' /tmp/python-src/openssl.cnf
        export OPENSSL_CONF=/tmp/python-src/openssl.cnf

        # Untar and build
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
}

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Install python from source if needed
if [ "${PYTHON_VERSION}" != "none" ]; then
    # Source /etc/os-release to get OS info
    . /etc/os-release
    # If ubuntu, PPAs allowed - install from there
    if [ "${ID}" = "ubuntu" ] && [ "${USE_PPA_IF_AVAILABLE}" = "true" ]; then
        install_from_ppa
    else
        install_from_source
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
