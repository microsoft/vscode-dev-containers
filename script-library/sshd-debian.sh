#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/sshd.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./sshd-debian.sh [SSH Port (don't use 22)] [non-root user] [start sshd now flag] [new password for user] [fix environment flag]
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
sed -i 's/session\s*required\s*pam_loginuid\.so/ession optional pam_loginuid.so/g' /etc/pam.d/sshd
sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i -E "s/#*\s*Port\s+.+/Port ${SSHD_PORT}/g" /etc/ssh/sshd_config

# Script to store variables that exist at the time the ENTRYPOINT is fired
STORE_ENV_SCRIPT="$(cat << 'EOF'
# Update default env - Need to do this here because its unclear where the ssh script was run in the Dockerfile.
# Unlike macOS and Windows, nearly everything is legal in file/path names so we need to do some escaping. We then
# need to modify /etc/environment and possibly /etc/profile and /etc/zsh/zshenv due to PATH hard coding in certain imges.
# Remove user/context specific default vars:
# - https://ss64.com/bash/syntax-variables.html#:~:text=Default%20Shell%20Variables
# - https://zsh.sourceforge.io/Doc/Release/Parameters.html
VARS_TO_FILTER_OUT='USER|USERNAME|GROUPS|HOME|SHELL|SHELLOPTS|HOST|HOSTNAME|IFS|FUNCNAME|FUNCNEST|OPTARG|OPTIND|OPTERR|OSTYPE|MACHTYPE|CPUTYPE|PPID|TTY|TTYIDLE|TRY_BLOCK_ERROR|TRY_BLOCK_INTERRUPT|PIPESTATUS|RANDOM|SECONDS|COMP_WORDS|COMP_CWORD|COMP_LINE|COMP_POINT|COMPREPLY|DIRSTACK|PWD|OLDPWD|TERM|TERMINFO|TERMINFO_DIRS|TERM_PROGRAM|TERM_PROGRAM_VERSION|COLORTERM|SHLVL|LOGNAME|MAIL|MAILPATH|MAILCHECK|BASH|BASH_ENV|BASH_VERSION|BASH_VERSINFO|UID|GID|EUID|EGID|LINENO|CDPATH|VENDOR|ZSH|ZSH_ARGZERO|ZSH_EXECUTION_STRING|ZSH_NAME|ZSH_PATCHLEVEL|ZSH_SCRIPT|ZSH_SUBSHELL|ZSH_VERSION|ENV'
BASE_ENV_VARS="$(declare -x +r +f | grep -vE "(${VARS_TO_FILTER_OUT})="| grep -oP '(declare\s+-x\s+)?\K.*=.*')"
ETC_ENV_VARS="$(cat /etc/environment 2>/dev/null || echo '')"
# Augment BASE_ENV_VARs with anything in ETC_ENV_VARS
while IFS= read -r variable_line; do
    VAR_NAME="${variable_line%%=*}"
    if [ "${VAR_NAME}" != "" ] && ! echo "${BASE_ENV_VARS}" | grep "${VAR_NAME}=" > /dev/null 2>&1; then
        BASE_ENV_VARS="$variable_line\n${BASE_ENV_VARS}"
    fi
done <<< "${ETC_ENV_VARS}"
echo -e "${BASE_ENV_VARS}" | sudoIf tee /etc/environment > /dev/null

# Wire in codespaces secret processing to zsh if present (since may have been added to image after script was run)
if [ -f  /etc/zsh/zlogin ] && ! grep '/etc/profile.d/00-restore-secrets.sh' /etc/zsh/zlogin > /dev/null 2>&1; then
    echo -e "if [ -f /etc/profile.d/00-restore-secrets.sh ]; then . /etc/profile.d/00-restore-secrets.sh; fi\n$(cat /etc/zsh/zlogin 2>/dev/null || echo '')" | sudoIf tee /etc/zsh/zlogin > /dev/null
fi

# Handle PATH hard coding in /etc/profile or /etc/zshenv
QUOTE_ESCAPED_PATH="${PATH//\"/\\\"}"
SED_ESCAPTED_PATH="${QUOTE_ESCAPED_PATH//\\%/\\\%}"
sudoIf sed -i -E "s%((^|\s)PATH=)([^\$]*)$%\2PATH=\"${SED_ESCAPTED_PATH:-\3}\"%" /etc/profile
if [ -f /etc/zsh/zshenv ]; then
    sudoIf sed -i -E "s%((^|\s)PATH=)([^\$]*)$%\2PATH=\"${SED_ESCAPTED_PATH:-\3}\"%" /etc/zsh/zshenv
fi

# Remove less complex scipt if present to avoid duplication
if [ -f "/etc/profile.d/00-restore-env.sh" ]; then
    sudoIf rm -f /etc/profile.d/00-restore-env.sh
fi

EOF
)"

# Script to ensure login shells get the latest Codespaces secrets
RESTORE_SECRETS_SCRIPT="$(cat << 'EOF'
#!/bin/sh
if [ "${CODESPACES}" != "true" ] || [ "${VSCDC_FIXED_SECRETS}" = "true" ]; then
    # Already run, so exit
    return
fi
if [ -f /workspaces/.codespaces/shared/.user-secrets.json ]; then
   $(cat /workspaces/.codespaces/shared/.user-secrets.json | jq -r '.[] | select (.type=="EnvironmentVariable") | "export "+.name+"=\""+.value+"\""')
fi
export VSCDC_FIXED_SECRETS=true
EOF
)"

# Write out a scripts that can be referenced as an ENTRYPOINT to auto-start sshd and fix login environments
tee /usr/local/share/ssh-init.sh > /dev/null \
<< 'EOF'
#!/usr/bin/env bash
# This script is intended to be run as root with a container that runs as root (even if you connect with a different user)
# However, it supports running as a user other than root if passwordless sudo is configured for that same user.

set -e 

sudoIf()
{
    if [ "$(id -u)" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

EOF
if [ "${FIX_ENVIRONMENT}" = "true" ]; then
    echo "$STORE_ENV_SCRIPT" >> /usr/local/share/ssh-init.sh
    echo "${RESTORE_SECRETS_SCRIPT}" > /etc/profile.d/00-restore-secrets.sh
    chmod +x /etc/profile.d/00-restore-secrets.sh
    # Remove less complex script if present to avoid path duplication
    rm -f /etc/profile.d/00-restore-env.sh
    # Wire in zsh if present
    if type zsh > /dev/null 2>&1; then
        echo -e "if [ -f /etc/profile.d/00-restore-secrets.sh ]; then . /etc/profile.d/00-restore-secrets.sh; fi\n$(cat /etc/zsh/zlogin 2>/dev/null || echo '')" > /etc/zsh/zlogin
    fi

fi
tee -a /usr/local/share/ssh-init.sh > /dev/null \
<< 'EOF'

# ** Start SSH server **
sudoIf /etc/init.d/ssh start 2>&1 | sudoIf tee /tmp/sshd.log > /dev/null

set +e
exec "$@"
EOF
chmod +x /usr/local/share/ssh-init.sh

# If we should start sshd now, do so
if [ "${START_SSHD}" = "true" ]; then
    /usr/local/share/ssh-init.sh
fi

# Output success details
echo -e "Done!\n\n- Port: ${SSHD_PORT}\n- User: ${USERNAME}"
if [ "${EMIT_PASSWORD}" = "true" ]; then
    echo "- Password: ${NEW_PASSWORD}"
fi
echo -e "\nForward port ${SSHD_PORT} to your local machine and run:\n\n  ssh -p ${SSHD_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${USERNAME}@localhost\n"
