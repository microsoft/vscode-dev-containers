#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/rust.md
#
# Syntax: ./rust-debian.sh [CARGO_HOME] [RUSTUP_HOME] [non-root user] [add CARGO/RUSTUP_HOME to rc files flag] [whether to update rust]

export CARGO_HOME=${1:-"/usr/local/cargo"}
export RUSTUP_HOME=${2:-"/usr/local/rustup"}
USERNAME=${3:-"automatic"}
UPDATE_RC=${4:-"true"}
UPDATE_RUST=${5:-"true"}

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
        echo -e "$1" | tee -a /etc/bash.bashrc >> /etc/zsh/zshrc
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Install curl, lldb, python3-minimal,and rust dependencies if missing
if ! dpkg -s curl ca-certificates lldb python3-minimal gcc libc6-dev > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends curl ca-certificates gcc libc6-dev
    apt-get -y install lldb python3-minimal libpython3.?
fi

# Install Rust
if ! type rustup > /dev/null 2>&1; then
    echo "Installing Rust..."
    mkdir -p "${CARGO_HOME}" "${RUSTUP_HOME}"
    chown ${USERNAME} "${CARGO_HOME}" "${RUSTUP_HOME}"
    su ${USERNAME} -c "curl --tlsv1.2 https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path --profile minimal 2>&1"
else 
    echo "Rust already installed. Skipping."
fi

su ${USERNAME} -c "$(cat << EOF
    set -e
    export PATH=${PATH}:${CARGO_HOME}/bin
    if [ "${UPDATE_RUST}" = "true" ]; then
        echo "Updating Rust..."
        rustup update 2>&1
    fi
    echo "Installing common Rust dependencies..."
    rustup component add rls rust-analysis rust-src rustfmt clippy 2>&1
EOF
)"

# Add CARGO_HOME, RUSTUP_HOME and bin directory into bashrc/zshrc files (unless disabled)
updaterc "export CARGO_HOME=\"${CARGO_HOME}\"\nexport RUSTUP_HOME=\"${RUSTUP_HOME}\"\nexport PATH=\"\${CARGO_HOME}/bin:\${PATH}\""

updaterc "$(cat << EOF
export RUSTUP_HOME="${RUSTUP_HOME}"
export CARGO_HOME="${CARGO_HOME}"
if [[ "\${PATH}" != *"\${CARGO_HOME}/bin"* ]]; then export PATH="\${PATH}:\${CARGO_HOME}/bin"; fi
EOF
)"


echo "Done!"

