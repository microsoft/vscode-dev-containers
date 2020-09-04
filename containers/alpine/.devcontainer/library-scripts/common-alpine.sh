#!/bin/ash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Syntax: ./common-alpine.sh <install zsh flag> <username> <user UID> <user GID> 

INSTALL_ZSH=${1:-"true"}
USERNAME=${2:-"vscode"}
USER_UID=${3:-1000}
USER_GID=${4:-1000}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run a root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Install git, bash, dependencies, and add a non-root user
apk update
apk add --no-cache \
    git \
    openssh-client \
    less \
    bash \
    libgcc \
    libstdc++ \
    curl \
    wget \
    unzip \
    nano \
    jq \
    gnupg \
    procps \
    coreutils \
    ca-certificates \
    krb5-libs \
    libintl \
    libssl1.1 \
    lttng-ust \
    tzdata \
    userspace-rcu \
    zlib \
    shadow

# Install man pages - package name varies between 3.12 and earlier versions
if apk info man > /dev/null 2>&1; then
    apk add man man-pages
else 
    apk add mandoc man-pages
fi

# Create or update a non-root user to match UID/GID - see https://aka.ms/vscode-remote/containers/non-root-user.
if id -u $USERNAME > /dev/null 2>&1; then
    # User exists, update if needed
    if [ "$USER_GID" != "$(id -G $USERNAME)" ]; then 
        groupmod --gid $USER_GID $USERNAME 
        usermod --gid $USER_GID $USERNAME
    fi
    if [ "$USER_UID" != "$(id -u $USERNAME)" ]; then 
        usermod --uid $USER_UID $USERNAME
    fi
else
    # Create user
    groupadd --gid $USER_GID $USERNAME
    useradd -s /bin/ash -K MAIL_DIR=/dev/null --uid $USER_UID --gid $USER_GID -m $USERNAME
fi

# Add add sudo support for non-root user
apk add --no-cache sudo
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

# Ensure ~/.local/bin is in the PATH for root and non-root users for bash. (zsh is later)
echo "export PATH=\$PATH:\$HOME/.local/bin" | tee -a /root/.bashrc >> /home/$USERNAME/.bashrc 
chown $USER_UID:$USER_GID /home/$USERNAME/.bashrc

# Optionally install and configure zsh
if [ "$INSTALL_ZSH" = "true" ] && [ ! -d "/root/.oh-my-zsh" ]; then 
    apk add --no-cache zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "export PATH=\$PATH:\$HOME/.local/bin" >> /root/.zshrc
    cp -R /root/.oh-my-zsh /home/$USERNAME
    cp /root/.zshrc /home/$USERNAME
    sed -i -e "s/\/root\/.oh-my-zsh/\/home\/$USERNAME\/.oh-my-zsh/g" /home/$USERNAME/.zshrc
    chown -R $USER_UID:$USER_GID /home/$USERNAME/.oh-my-zsh /home/$USERNAME/.zshrc
fi
echo "Done!"
