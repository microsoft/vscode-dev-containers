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
USERNAME="${2:-"automatic"}"
NIX_PACKAGES="${4:-"none"}"
NIXFILE_PATH="${5:-"none"}"
NIX_GPG_KEYS="B541D55301270E0BCF15CA5D8170B4726D7198DE"
GPG_KEY_SERVERS="keyserver hkp://keyserver.ubuntu.com:80
keyserver hkps://keys.openpgp.org
keyserver hkp://keyserver.pgp.com"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# If in automatic mode, determine if a user already exists, if not use root
detect_user() {
    local user_variable_name=${1:-username}
    local possible_users=${2:-("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")}
    if [ "${!user_variable_name}" = "auto" ] || [ "${!user_variable_name}" = "automatic" ]; then
        declare -g ${user_variable_name}=""
        for current_user in ${possible_users[@]}; do
            if id -u "${current_user}" > /dev/null 2>&1; then
                declare -g ${user_variable_name}="${current_user}"
                break
            fi
        done
    fi
    if [ "${!user_variable_name}" = "" ] || [ "${!user_variable_name}" = "none" ] || ! id -u "${!user_variable_name}" > /dev/null 2>&1; then
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


update_rc_file() {
    # see if folder containing file exists
    local rc_file_folder="$(dirname "$1")"
    if [ ! -d "${rc_file_folder}" ]; then
        echo "${rc_file_folder} does not exist. Skipping update of $1."
    elif [ ! -e "$1" ] || [[ "$(cat "$1")" != *"$2"* ]]; then
        echo "$2" >> "$1"
    fi
}

if [ -e "/nix" ]; then
    echo "(!) Nix is already installed! Aborting."
    exit 0
fi

# Verify dependencies
check_command curl curl ca-certificates 
check_command gpg2 gnupg2
check_command dirmngr dirmngr
check_command xz xz-utils
check_command git git

# Determine version
find_version_from_git_tags NIX_VERSION https://github.com/NixOS/nix "tags/"

detect_user USERNAME
if [ "${USERNAME}" = "root" ]; then
    USERNAME=nix
    groupadd -g 1000 nix
    useradd -s /bin/bash -u 1000 -g 1000 -m nix
fi
# Create a nixuser group to help deal with UID/GID changes, make that the default group for the user we will install as
groupadd --system -r nixusers
original_group="$(id -g "${USERNAME}")"
original_uid="$(id -u "${USERNAME}")"
usermod -g nixusers "${USERNAME}"

# Adapted from https://nixos.org/download.html#nix-verify-installation
orig_cwd="$(pwd)"
mkdir -p /nix /tmp/nix
chown "${USERNAME}:nixusers" /nix
cd /tmp/nix
receive_gpg_keys NIX_GPG_KEYS
curl -sSLf -o ./install-nix https://releases.nixos.org/nix/nix-${NIX_VERSION}/install
curl -sSLf -o ./install-nix.asc https://releases.nixos.org/nix/nix-${NIX_VERSION}/install.asc
gpg2 --verify ./install-nix.asc
cd "${orig_cwd}"
# Install and post-install processing
su ${USERNAME} -c "$(cat << EOF 
    set -e
    sh /tmp/nix/install-nix --no-daemon --no-modify-profile
    ln -s /nix/var/nix/profiles/per-user/${USERNAME}/profile /nix/var/nix/profiles/default

    . /home/${USERNAME}/.nix-profile/etc/profile.d/nix.sh
    if [ ! -z "${PACKAGE_LIST}" ] && [ "${PACKAGE_LIST}" != "none" ]; then
        nix-env --install ${PACKAGE_LIST}
    fi
    if [ "${NIXFILE_PATH}" != "none" ] && [ -r "${NIXFILE_PATH}" ]; then
        nix-env --install -f "${NIXFILE_PATH}"
    fi
    nix-collect-garbage --delete-old
    nix-store --optimise
EOF
)"
rm -rf /tmp/nix
# Restore default group for we used to install 
usermod -a -G nixusers -g "${original_group}" "${USERNAME}"


# Set nix config
mkdir -p /etc/nix
cat << EOF >> /etc/nix/nix.conf
sandbox = false
trusted-users = ${USERNAME}
EOF

# Setup nixbld group, dir to allow root to function if preferred
if ! grep -e "^nixbld:" /etc/group > /dev/null 2>&1; then
    groupadd -g 30000 nixbld

fi
for i in $(seq 1 10); do
    nixbuild_user="nixbuild${i}"
    if ! id "${nixbuild_user}" > /dev/null 2>&1; then
        useradd --system --home-dir /var/empty --gid 30000 --groups nixbld --no-user-group --shell /usr/sbin/nologin --uid $((30000 + i)) "${nixbuild_user}"
    fi
done

# Setup channels for root user to avoid conflicts, but link profile
cp -R /home/${USERNAME}/.nix-channels /home/${USERNAME}/.nix-defexpr /home/${USERNAME}/.nix-channels /root/
cp  /home/${USERNAME}/.nix-channels /root/.nix-channels
ln -s /nix/var/nix/profiles/default /root/.nix-profile

# Setup rcs and profiles
snippet='
if [ "${PATH#*/nix/var/nix/profiles/default/bin}" = "${PATH}" ]; then export PATH=/nix/var/nix/profiles/default/bin:${PATH}; fi
if [ "${PATH#*$HOME/.nix-profile/bin}" = "${PATH}" ]; then if [ -z "$USER" ]; then USER=$(whoami); fi; . /nix/var/nix/profiles/default/etc/profile.d/nix.sh; fi
'
update_rc_file /etc/bash.bashrc "${snippet}"
update_rc_file /etc/zsh/zshenv "${snippet}"
update_rc_file /etc/profile.d/nix.sh "${snippet}"
chmod +x /etc/profile.d/nix.sh

# Add optional entrypoint script to attempt to tweak privs for user nix profile if needed
echo "Setting up entrypoint..."
cat << EOF > /usr/local/share/nix-init.sh
#!/bin/bash
# Nix is very picky about privs under /nix/var, so make sure they are correct in the event the 
# user's UID changes. The group privs should be enough for the contents of /nix/store, but update dirs
if [ "\$(stat -c '%U' /nix/var/nix/profiles/per-user/${USERNAME})" != "${USERNAME}" ]; then
    if [ "\$(id -u)" = "0" ]; then
        chown ${USERNAME} /nix /nix/store /nix/store/.links
        find /nix/var -uid ${original_uid} -execdir chown ${USERNAME} "{}" \+ &
    elif type sudo > /dev/null 2>&1; then 
        sudo chown ${USERNAME} /nix /nix/store /nix/store/.links
        sudo find /nix/var -uid ${original_uid} -execdir chown ${USERNAME} "{}" \+ &
    else
        echo "WARNING: Unable to change nix profile privledges for ${USERNAME}. Try running the container as root."
    fi
fi
exec "\$@"
EOF
chmod +x /usr/local/share/nix-init.sh

echo "Done!"