#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/nix.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./nix-debian.sh [version] [username] [use unstable channel] [space separated package list] [nix file]

set -e

NIX_VERSION="${1:-"latest"}"
USERNAME="${2:-"vscode"}"
NIX_PACKAGES="${4:-"none"}"
NIXFILE_PATH="${5:-"$(pwd)/default.nix"}"
NIX_GPG_KEYS="B541D55301270E0BCF15CA5D8170B4726D7198DE"
GPG_KEY_SERVERS="keyserver hkp://keyserver.ubuntu.com:80
keyserver hkps://keys.openpgp.org
keyserver hkp://keyserver.pgp.com"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# If in automatic mode, determine if a user already exists, if not use vscode
detect_user() {
    local user_variable_name=${1:-username}
    local user_variable_value=${!user_variable_name}
    local possible_users=${2:-("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")}
    if [ "${user_variable_value}" = "auto" ] || [ "${user_variable_value}" = "automatic" ]; then
        declare -g ${user_variable_name}=vscode
        for current_user in ${possible_users[@]}; do
            if id -u ${current_user} > /dev/null 2>&1; then
                declare -g ${user_variable_name}=${current_user}
                break
            fi
        done
    elif [ "${user_variable_value}" = "none" ] || ! id "${user_variable_value}" > /dev/null 2>&1; then
        declare -g ${user_variable_name}=root
    fi
}

# Import the specified key in a variable name passed in as 
receive_gpg_keys() {
    get_common_setting $1
    local keys=${!1}
    get_common_setting GPG_KEY_SERVERS true
    local keyring_args=""
    if [ ! -z "$2" ]; then
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
        echo "(!) Failed to get gpg key."
        exit 1
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

# Checks if command exists, installs it if not
# check_command <command> <package to install>...
check_command() {
    command_to_check=$1
    shift
    if type "${command_to_check}" > /dev/null 2>&1; then
        return 0
    fi
    apt_get_update_if_needed
    apt-get -y install --no-install-recommends "$@"
}

# Figure out correct version of a three part version number is not passed
find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    # Normally a "v" is used before the version number, but support alternate cases
    local prefix=${3:-"tags/v"}
    # Some repositories use "_" instead of "." for version number part separation, support that
    local separator=${4:-"."}
    # Some tools release versions that omit the last digit (e.g. go)
    local last_part_optional=${5:-"false"}
    # Some repositories may have tags that include a suffix (e.g. actions/node-versions)
    local version_suffix_regex=$6

    local escaped_separator=${separator//./\\.}
    local break_fix_digit_regex
    if [ "${last_part_optional}" = "true" ]; then
        break_fix_digit_regex="(${escaped_separator}[0-9]+)?"
    else
        break_fix_digit_regex="${escaped_separator}[0-9]+"
    fi    
    local version_regex="[0-9]+${escaped_separator}[0-9]+${break_fix_digit_regex}${version_suffix_regex//./\\.}"
    # If we're passed a matching version number, just return it, otherwise look for a version
    if ! echo "${requested_version}" | grep -E "^${versionMatchRegex}$" > /dev/null 2>&1; then
        local version_list="$(git ls-remote --tags ${repository} | grep -oP "${prefix}\\K${version_regex}$" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g ${variable_name}="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|${version_suffix_regex//./\\.}|$)")"
            set -e
        fi
        if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
            echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
            exit 1
        fi
    fi
    echo "Adjusted ${variable_name}=${!variable_name}"
}


if [ -e "/nix" ]; then
    echo "(!) Nix is already installed! Aborting."
    exit 1
fi

# Verify dependencies
check_command curl curl ca-certificates 
check_command gpg2 gnupg2
check_command dirmngr dirmngr
check_command xz xz-utils
check_command git git

detect_user USERNAME
if [ "${USERNAME}" = "root" ]; then
    echo -e "(!) Nix requires a non-root user to function. Add a non-root user with a UID of 1000.\nYou may use the following script to do this for you:\n\nhttps://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/common.md"
fi

# Determine version
find_version_from_git_tags NIX_VERSION https://github.com/NixOS/nix "tags/"

# Create nix group, dir, and set sticky bit to handle user UID/GID changes
if ! cat /etc/group | grep -e "^nix:" > /dev/null 2>&1; then
    groupadd -r nix
fi
if ! cat /etc/group | grep -e "^nixbld:" > /dev/null 2>&1; then
    groupadd -g 30000 nixbld
    useradd --home-dir /var/empty --shell /usr/sbin/nologin --system -u 30000 -g nixbld -G nixbld,nix nixbld
fi
usermod -a -G nix ${USERNAME}
umask 0002
mkdir -p /nix
chown ":nix" /nix
chmod g+s /nix 

# Adapted from https://nixos.org/download.html#nix-verify-installation
orig_cwd="$(pwd)"
mkdir -p /tmp/nix
cd /tmp/nix
receive_gpg_keys NIX_GPG_KEYS
curl -sSLf -o install-nix https://releases.nixos.org/nix/nix-${NIX_VERSION}/install
curl -sSLf -o install-nix.asc https://releases.nixos.org/nix/nix-${NIX_VERSION}/install.asc
gpg2 --verify ./install-nix.asc
su $USERNAME -c 'sh ./install-nix --no-daemon'
cd "${orig_cwd}"
rm -rf /tmp/nix

# Post-install processing
post_processing_script='. $HOME/.nix-profile/etc/profile.d/nix.sh'
if [ ! -z "${PACKAGE_LIST}" ] && [ "${PACKAGE_LIST}" != "none" ]; then
    post_processing_script="${post_processing_script} && nix-env --install ${PACKAGE_LIST}"
fi
if [ -r "${NIXFILE_PATH}" ] && [ "${NIXFILE_PATH}" != "none" ]; then
    post_processing_script="${post_processing_script} && nix-env --install -f \"${NIXFILE_PATH}\""
fi
post_processing_script="${post_processing_script} && nix-collect-garbage --delete-old && nix-store --optimise"
su ${USERNAME} -c "${post_processing_script}"

# Setup privs and set sticky bit to handle user UID/GID changes
echo "Updating permissions..."
chown -R ":nix" /nix
chmod -R g+rw /nix
find /nix -type d | xargs chmod g+s

# Initalize nix from interactive shell in addition to login shells (~/.profile was added by installer)
# The init script takes 2 ms, a check for nix existing is 1 ms, so adding a command check for a login interactive shell would be 4 ms regardless
nix_snippet="if [ -e /home/${USERNAME}/.nix-profile/etc/profile.d/nix.sh ]; then . /home/${USERNAME}/.nix-profile/etc/profile.d/nix.sh; fi"
echo "${nix_snippet}" >> /home/${USERNAME}/.bashrc 
if type zsh > /dev/null 2>&1; then
    echo "${nix_snippet}" | tee -a /home/${USERNAME}/.zshrc >> /home/${USERNAME}/.zenv
fi

echo -e "\nNix is now available for user ${USERNAME}.\n\nDone!"