#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/sshd.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./sshd-debian.sh [SSH Port (don't use 22)] [non-root user] [start sshd now flag] [new password for user]
#
# Note: You can change your user's password with "sudo passwd $(whoami)" (or just "passwd" if running as root).

SSHD_PORT=${1:-"2222"}
USERNAME=${2:-"automatic"}
START_SSHD=${3:-"false"}
NEW_PASSWORD=${4:-"skip"}
FIX_ENVIRONMENT=${5:-"true"}

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

# Install openssh-server openssh-client
if ! dpkg -s openssh-server openssh-client lsof jq > /dev/null 2>&1; then
    apt-get-update-if-needed
    apt-get -y install --no-install-recommends openssh-server openssh-client lsof jq
fi

# Generate password if new password set to the word "random"
if [ "${NEW_PASSWORD}" = "random" ]; then
    NEW_PASSWORD="$(openssl rand -hex 16)"
    EMIT_PASSWORD="true"
fi

# If new password not set to skip, set it for the specified user
if [ "${NEW_PASSWORD}" != "skip" ]; then
    echo "${USERNAME}:${NEW_PASSWORD}" | chpasswd
    if [ "${NEW_PASSWORD}" != "root" ]; then
        usermod -aG ssh ${USERNAME}
    fi
fi

# Setup sshd
mkdir -p /var/run/sshd
sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i -E "s/#*\s*Port\s+.+/Port ${SSHD_PORT}/g" /etc/ssh/sshd_config

# Write out a script that can be referenced as an ENTRYPOINT to auto-start sshd
tee /usr/local/share/ssh-init.sh > /dev/null \
<< 'EOF'
#!/usr/bin/env bash
set -e 

sudoIf()
{
    if [ "$(id -u)" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# The files created here are used by /etc/profile.d/00-fix-login-env.sh.
sudoIf mkdir -p /usr/local/etc/vscode-dev-containers
declare -x | grep -vE '(USER|HOME|SHELL|PWD|OLDPWD|TERM|TERM_PROGRAM|TERM_PROGRAM_VERSION|SHLVL|HOSTNAME|LOGNAME|MAIL)=' | grep -oP '(declare\s+-x\s+)?\K.*=.*' | sudoIf tee /usr/local/etc/vscode-dev-containers/base-env > /dev/null

# Start SSH server
sudoIf /etc/init.d/ssh start 2>&1 | sudoIf tee /tmp/sshd.log > /dev/null

set +e
exec "$@"
EOF
chmod +x /usr/local/share/ssh-init.sh

# Write out a script to ensure login shells get variables or the PATH that were set in the container image
SH_RESTORE_ENV_SCRIPT="$(cat << 'EOF'
#!/bin/sh
# This script is intended to be sourced, so it uses posix syntax where possible and detects zsh for cases where things differ

if [ "${VSCDC_FIX_LOGIN_ENV}" = "true" ]; then
    # Already run, so exit
    return
fi

export VSCDC_FIX_LOGIN_ENV=true
__vscdc_restore_env() {
    local base_env_vars
    local base_shell_path
    # Grab codespaces secrets if present
    if [ -f /workspaces/.codespaces/shared/.user-secrets.json ]; then
        base_env_vars="$(cat /workspaces/.codespaces/shared/.user-secrets.json | jq -r '.[] | select (.type=="EnvironmentVariable") | .name+"=\""+.value+"\""')"
    fi
    if [ -f /usr/local/etc/vscode-dev-containers/base-env ]; then
        base_env_vars="${base_env_vars}$(echo && cat /usr/local/etc/vscode-dev-containers/base-env)"
    fi
    if [ -v base_env_vars ]; then
        # Add any missing env vars saved off earlier
        local variable_line
        while read variable_line; do
            local var_name="${variable_line%%=*}"
            if [ "${var_name}" = "PATH" ]; then
                local var_value="${variable_line##*=\"}"
                base_shell_path="${var_value%?}"
            elif [ "${var_name}" != "" ] && [ ! -v "${var_name}" ]; then
                # All values are quoted, so get everything past the first quote and remove the last
                local var_value="${variable_line##*=\"}"
                export ${var_name}="${var_value%?}"
            fi
        done <<< "$base_env_vars"
    fi
    # Unlike other properties, the starting PATH can get set in a few different ways. Debian sets it in /etc/profile while Ubuntu 
    # takes it from /env/environment, both of which are a problem if the PATH was modified using the ENV directive in a Dockerfile.
    if [ -v base_shell_path ] && [ "$PATH" = "${PATH#*$base_shell_path}" ]; then
        local clean_shell_path
        if [ "$(lsof -p $$ | awk '(NR==2) {print $1}')" = "zsh" ]; then
            # zsh always sources /etc/zsh/zshenv so getting a clean environment is simple and we just have to worry about /etc/environment
            clean_shell_path="$(env -i - PATH="$(PATH=""; . /etc/environment; echo "$PATH" 2>/dev/null)" /usr/bin/zsh --no-globalrcs --no-rcs -c 'echo $PATH' 2>/dev/null)"
        else 
            # If we're in a situation where we've got a fresh environment, replace this shell's base path with the image base path. First,
            # find true base path - Debian hard codes it in /etc/profile while Ubuntu gets it from /etc/environment, so its a bit tricky to get.
            # Since the true base path can vary by user (particularly for Debian), we need to figure it out here instead of up-front.
            if [ ! -f /tmp/clean-profile ]; then
                cp /etc/profile /tmp/clean-profile
                sed -i 's/\/etc\/profile\.d/\/tmp\/ignore-me.d/g' /tmp/clean-profile
                sed -i 's/\/etc\/bash\.bashrc/\/tmp\/noop.sh/g' /tmp/clean-profile
            fi
            mkdir -p /tmp/ignore-me.d
            touch /tmp/noop.sh
            clean_shell_path="$(env -i - BASH="" PS1="" /bin/bash --noprofile --norc -c '. /tmp/clean-profile; echo $PATH' 2>/dev/null)"
            # Escape the path for bash/sh
            clean_shell_path="${clean_shell_path//\//\\\/}"
        fi
        # Replace it if it exists in the path with the base_shell_path saved off earlier
        export PATH="${PATH/$clean_shell_path/$base_shell_path}"
    fi
}
__vscdc_restore_env
unset -f __vscdc_restore_env
EOF
)"
if [ "${FIX_ENVIRONMENT}" = "true" ]; then
    echo "${SH_RESTORE_ENV_SCRIPT}" > /etc/profile.d/00-fix-login-env.sh
    chmod +x /etc/profile.d/00-fix-login-env.sh
    # Remove less complex scipt if present to avoid duplication
    rm -f /etc/profile.d/00-restore-env.sh
    # Wire in zsh if present
    if type zsh > /dev/null 2>&1; then
        echo -e "if [ -f /etc/profile.d/00-fix-login-env.sh ]; then . /etc/profile.d/00-fix-login-env.sh; fi\n$(cat /etc/zsh/zlogin 2>/dev/null || echo '')" > /etc/zsh/zlogin
    fi
fi

# If we should start sshd now, do so
if [ "${START_SSHD}" = "true" ]; then
    /usr/local/share/ssh-init.sh
fi

# Write out result
echo -e "Done!\n\n- Port: ${SSHD_PORT}\n- User: ${USERNAME}"
if [ "${EMIT_PASSWORD}" = "true" ]; then
    echo "- Password: ${NEW_PASSWORD}"
fi
echo -e "\nForward port ${SSHD_PORT} to your local machine and run:\n\n  ssh -p ${SSHD_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${USERNAME}@localhost\n"
