#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Syntax: ./ruby-debian.sh [Ruby version] [non-root user] [Add rvm to rc files flag]

RUBY_VERSION=${1:-"stable"}
USERNAME=${2:-"vscode"}
UPDATE_RC=${3:-"true"}

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

# Install curl, software-properties-common if missing
if ! dpkg -s curl ca-certificates software-properties-common > /dev/null 2>&1; then
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get -y install --no-install-recommends curl ca-certificates software-properties-common
fi

# Just install Ruby if RVM already installed
if [ -d "/usr/local/rvm" ]; then
    echo "Ruby Version Manager already exists. Installing specified Ruby version."
    su ${USERNAME} -c "source /usr/local/rvm/scripts/rvm && rvm install ${RUBY_VERSION}"
    source /usr/local/rvm/scripts/rvm
    rvm cleanup all 
    gem cleanup
    exit 0
fi

# Use a temporary locaiton for gpg keys to avoid polluting image
export GNUPGHOME="/tmp/rvm-gnupg"
mkdir -p ${GNUPGHOME}
echo "disable-ipv6" >> ${GNUPGHOME}/dirmngr.conf
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB 2>&1 \

# Install RVM
curl -sSL https://get.rvm.io | bash -s "${RUBY_VERSION}" --ruby --with-default-gems="rake ruby-debug-ide debase" 2>&1
usermod -aG rvm ${USERNAME}
su ${USERNAME} -c "source /usr/local/rvm/scripts/rvm && rvm fix-permissions system"
rm -rf ${GNUPGHOME}
source /usr/local/rvm/scripts/rvm
rvm cleanup all 
gem cleanup

# Add sourcing of rvm into bashrc/zshrc files (unless disabled)
if [ "${UPDATE_RC}" = "true" ]; then
    RC_SNIPPET="source /usr/local/rvm/scripts/rvm"
    echo -e ${RC_SNIPPET} | tee -a /root/.bashrc /root/.zshrc >> /etc/skel/.bashrc 
    if [ "${USERNAME}" != "root" ]; then
        echo -e ${RC_SNIPPET} | tee -a /home/${USERNAME}/.bashrc >> /home/${USERNAME}/.zshrc 
    fi
fi
echo "Done!"