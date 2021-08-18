#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/ruby.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./ruby-debian.sh [Ruby version] [non-root user] [Add to rc files flag] [Install tools flag]

RUBY_VERSION=${1:-"latest"}
USERNAME=${2:-"automatic"}
UPDATE_RC=${3:-"true"}
INSTALL_RUBY_TOOLS=${6:-"true"}

DEFAULT_GEMS="rake ruby-debug-ide debase"
RVM_GPG_KEYS="409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB"
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
        keyring_args="--no-default-keyring --keyring \"$2\""
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


# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

architecture="$(uname -m)"
if [ "${architecture}" != "amd64" ] && [ "${architecture}" != "x86_64" ] && [ "${architecture}" != "arm64" ] && [ "${architecture}" != "aarch64" ]; then
    echo "(!) Architecture $architecture unsupported"
    exit 1
fi

# Install dependencies
check_packages curl ca-certificates software-properties-common build-essential gnupg2 libreadline-dev \
    procps dirmngr gawk autoconf automake bison libffi-dev libgdbm-dev libncurses5-dev \
    libsqlite3-dev libtool libyaml-dev pkg-config sqlite3 zlib1g-dev libgmp-dev libssl-dev
if ! type git > /dev/null 2>&1; then
    apt_get_update_if_needed
    apt-get -y install --no-install-recommends git
fi


# Figure out correct version of a three part version number is not passed
find_version_from_git_tags RUBY_VERSION "https://github.com/ruby/ruby" "tags/v" "_"

# Just install Ruby if RVM already installed
if [ -d "/usr/local/rvm" ]; then
    echo "Ruby Version Manager already exists."
    if [ "${RUBY_VERSION}" != "none" ]; then
        echo "Installing specified Ruby version."
        su ${USERNAME} -c "&& rvm install ruby ${RUBY_VERSION}"
    fi
    SKIP_GEM_INSTALL="false"
else
    # Install RVM
    receive_gpg_keys RVM_GPG_KEYS
    # Determine appropriate settings for rvm installer
    if [ "${RUBY_VERSION}" = "none" ]; then
        RVM_INSTALL_ARGS=""
    else
        if [ "${RUBY_VERSION}" = "latest" ] || [ "${RUBY_VERSION}" = "current" ] || [ "${RUBY_VERSION}" = "lts" ]; then
            RVM_INSTALL_ARGS="--ruby"
            RUBY_VERSION=""
        else
            RVM_INSTALL_ARGS="--ruby=${RUBY_VERSION}"
        fi
        if [ "${INSTALL_RUBY_TOOLS}" = "true" ]; then
            SKIP_GEM_INSTALL="true"
        else 
            DEFAULT_GEMS=""
        fi
    fi
    curl -sSL https://get.rvm.io | bash -s stable --ignore-dotfiles ${RVM_INSTALL_ARGS} --with-default-gems="${DEFAULT_GEMS}" 2>&1
    usermod -aG rvm ${USERNAME}
    su ${USERNAME} -c ". /usr/local/rvm/scripts/rvm && rvm fix-permissions system"
    rm -rf ${GNUPGHOME}
fi

if [ "${INSTALL_RUBY_TOOLS}" = "true" ]; then
    # Non-root user may not have "gem" in path when script is run and no ruby version
    # is installed by rvm, so handle this by using root's default gem in this case
    ROOT_GEM='$(which gem || echo "")'
    su ${USERNAME} -c ". /usr/local/rvm/scripts/rvm && \"$(which gem || echo ${ROOT_GEM})\" install ${DEFAULT_GEMS}"
fi

# VS Code server usually first in the path, so silence annoying rvm warning (that does not apply) and then source it
updaterc "if ! grep rvm_silence_path_mismatch_check_flag \$HOME/.rvmrc > /dev/null 2>&1; then echo 'rvm_silence_path_mismatch_check_flag=1' >> \$HOME/.rvmrc; fi\nsource /usr/local/rvm/scripts/rvm > /dev/null 2>&1"

# Install rbenv/ruby-build for good measure
git clone --depth=1 \
    -c core.eol=lf \
    -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    https://github.com/rbenv/rbenv.git /usr/local/share/rbenv
ln -s /usr/local/share/rbenv/bin/rbenv /usr/local/bin
updaterc 'eval "$(rbenv init -)"'
git clone --depth=1 \
    -c core.eol=lf \
    -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    https://github.com/rbenv/ruby-build.git /usr/local/share/ruby-build
mkdir -p /root/.rbenv/plugins
ln -s /usr/local/share/ruby-build /root/.rbenv/plugins/ruby-build
if [ "${USERNAME}" != "root" ]; then
    mkdir -p /home/${USERNAME}/.rbenv/plugins
    chown -R ${USERNAME} /home/${USERNAME}/.rbenv
    ln -s /usr/local/share/ruby-build /home/${USERNAME}/.rbenv/plugins/ruby-build
fi

# Clean up
source /usr/local/rvm/scripts/rvm
rvm cleanup all 
gem cleanup
echo "Done!"
