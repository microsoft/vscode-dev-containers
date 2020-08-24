#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Syntax: ./go-debian.sh [Go version] [Go install path] [GOPATH] [non-root user] [Add GOPATH, GOROOT to rc files flag] [install tools]

TARGET_GO_VERSION=${1:-"1.15"}
TARGET_GOROOT=${2:-"/usr/local/go"}
TARGET_GOPATH=${3:-"/go"}
USERNAME=${4:-"vscode"}
UPDATE_RC=${5:-"true"}
INSTALL_GO_TOOLS=${6:-"true"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run a root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Treat a user name of "none" or non-existant user as root
if [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

export DEBIAN_FRONTEND=noninteractive

# Install curl, tar, git, other dependencies if missing
if ! dpkg -s curl ca-certificates tar git g++ gcc libc6-dev make pkg-config > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends curl ca-certificates tar git g++ gcc libc6-dev make pkg-config
fi

# Install Go
GO_INSTALL_SCRIPT="$(cat <<EOF
    set -e
    echo "Downloading Go ${TARGET_GO_VERSION}..."
    curl -sSL -o /tmp/go.tar.gz "https://golang.org/dl/go${TARGET_GO_VERSION}.linux-amd64.tar.gz"
    echo "Extracting Go ${TARGET_GO_VERSION}..."
    tar -xzf /tmp/go.tar.gz -C "${TARGET_GOROOT}" --strip-components=1
    rm -f /tmp/go.tar.gz
EOF
)"
if ! type go > /dev/null 2>&1; then
    mkdir -p "${TARGET_GOROOT}" "${TARGET_GOPATH}" 
    chown ${USERNAME}:root "${TARGET_GOROOT}" "${TARGET_GOPATH}"
    su ${USERNAME} -c "${GO_INSTALL_SCRIPT}"
else
    echo "Go already installed. Skipping."
fi

# Install Go tools
GO_TOOLS_WITH_MODULES="\
    golang.org/x/tools/gopls \
    honnef.co/go/tools/... \
    golang.org/x/tools/cmd/gorename \
    golang.org/x/tools/cmd/goimports \
    golang.org/x/tools/cmd/guru \
    golang.org/x/lint/golint \
    github.com/mdempsky/gocode \
    github.com/cweill/gotests/... \
    github.com/haya14busa/goplay/cmd/goplay \
    github.com/sqs/goreturns \
    github.com/josharian/impl \
    github.com/davidrjenni/reftools/cmd/fillstruct \
    github.com/uudashr/gopkgs/v2/cmd/gopkgs \
    github.com/ramya-rao-a/go-outline \
    github.com/acroca/go-symbols \
    github.com/godoctor/godoctor \
    github.com/rogpeppe/godef \
    github.com/zmb3/gogetdoc \
    github.com/fatih/gomodifytags \
    github.com/mgechev/revive \
    github.com/go-delve/delve/cmd/dlv"
if [ "${INSTALL_GO_TOOLS}" = "true" ]; then
    echo "Installing common Go tools..."
    export PATH=${TARGET_GOROOT}/bin:${PATH}
    mkdir -p /tmp/gotools
    cd /tmp/gotools
    export GOPATH=/tmp/gotools
    export GOCACHE=/tmp/gotools/cache

    # Go tools w/module support
    export GO111MODULE=on
    (echo "${GO_TOOLS_WITH_MODULES}" | xargs -n 1 go get -v )2>&1

    # gocode-gomod
    export GO111MODULE=auto
    go get -v -d github.com/stamblerre/gocode 2>&1
    go build -o gocode-gomod github.com/stamblerre/gocode

    # golangci-lint
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin 2>&1

    # Move Go tools into path and clean up
    mv /tmp/gotools/bin/* /usr/local/bin/
    mv gocode-gomod /usr/local/bin/
    rm -rf /tmp/gotools
fi

# Add GOPATH variable and bin directory into PATH in bashrc/zshrc files (unless disabled)
if [ "${UPDATE_RC}" = "true" ]; then
    RC_SNIPPET="export GOPATH=\"${TARGET_GOPATH}\"\nexport GOROOT=\"${TARGET_GOROOT}\"\nexport PATH=\"\${GOROOT}/bin:\${PATH}\""
    echo -e ${RC_SNIPPET} | tee -a /root/.bashrc /root/.zshrc >> /etc/skel/.bashrc 
    if [ "${USERNAME}" != "root" ]; then
        echo -e ${RC_SNIPPET} | tee -a /home/${USERNAME}/.bashrc >> /home/${USERNAME}/.zshrc 
    fi
fi
echo "Done!"

