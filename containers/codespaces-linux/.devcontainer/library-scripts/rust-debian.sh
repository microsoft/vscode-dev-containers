#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Syntax: ./rust-debian.sh <CARGO_HOME> <RUSTUP_HOME>

export CARGO_HOME=${1:-"/usr/local/cargo"}
export RUSTUP_HOME=${2:-"/usr/local/rustup"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run a root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Install curl, lldb, python3-minimal if missing
if ! dpkg -s curl ca-certificates lldb python3-minimal > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends curl ca-certificates 
    apt-get -y install lldb python3-minimal libpython3.?
fi

# Install Rust
if ! type rustup > /dev/null 2>&1; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | bash -s -- -y 2>&1
    #chmod -R 777 ${CARGO_HOME} ${RUSTUP_HOME}
    source ${CARGO_HOME}/env
fi
echo "Installing common Rust dependencies..."
rustup update 2>&1
rustup component add rls rust-analysis rust-src rustfmt clippy 2>&1
