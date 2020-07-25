#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
FROM mcr.microsoft.com/oryx/build:vso-20200706.2 as kitchensink

ARG BASH_PROMPT="PS1='\[\e]0;\u: \w\a\]\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '"
ARG FISH_PROMPT="function fish_prompt\n    set_color green\n    echo -n (whoami)\n    set_color normal\n    echo -n \":\"\n    set_color blue\n    echo -n (pwd)\n    set_color normal\n    echo -n \"> \"\nend\n"
ARG ZSH_PROMPT="autoload -Uz promptinit\npromptinit\nprompt adam2"

# Define extra paths:
# Language executables provided by Oryx -  see https://github.com/microsoft/Oryx/blob/master/images/build/slim.Dockerfile#L223
ARG EXTRA_PATHS="/opt/oryx:/opt/nodejs/lts/bin:/opt/python/latest/bin:/opt/yarn/stable/bin:/home/codespace/.dotnet/tools"
ARG EXTRA_PATHS_OVERRIDES="~/.dotnet"
# ~/.local/bin - For 'pip install --user'
# ~/.npm-global/bin - For npm global bin directory in user directory
ARG USER_EXTRA_PATHS="${EXTRA_PATHS}:~/.local/bin:~/.npm-global/bin"

ARG NVS_HOME="/home/codespace/.nvs"

ARG DeveloperBuild

# Default to bash shell (other shells available at /usr/bin/fish and /usr/bin/zsh)
ENV SHELL=/bin/bash

ENV ORYX_ENV_TYPE=vsonline-present

# Enable dotnet tools to be used.
ENV DOTNET_ROOT=/home/codespace/.dotnet

# Add script to fix .NET Core pathing
ADD symlinkDotNetCore.sh /tmp/codespace/symlinkDotNetCore.sh

ADD git-ed.sh /tmp/codespace/git-ed.sh

# Install packages, setup codespace user
RUN apt-get update -yq\
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -yq install --no-install-recommends apt-utils dialog 2>&1 \
    && apt-get install -yq \
        default-jdk \
        vim \
        sudo \
        xtail \
        fish \
        zsh \
        curl \
        gnupg \
        apt-transport-https \
        lsb-release \
        software-properties-common \
        unzip \
    #
    # Be sure git is up to date due to DSA 4659-1, DSA 4657-1
    && apt-get upgrade -yq git \
    #
    # Install GitHub CLI v 0.11.0
    && echo "Downloading github CLI..." \
    && curl -OL https://github.com/cli/cli/releases/download/v0.11.0/gh_0.11.0_linux_amd64.deb \
    && echo "Installing github CLI..." \
    && apt install ./gh_0.11.0_linux_amd64.deb \
    && echo "Removing github CLI deb file after installation..." \
    && rm -rf ./gh_0.11.0_linux_amd64.deb \
    #
    # Optionally install debugger for development of VSO
    && if [ -z $DeveloperBuild ]; then \
        echo "not including debugger" ; \
    else \
        curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg ; \
    fi \
    #
    # Install Live Share dependencies
    && curl -sSL -o vsls-linux-prereq-script.sh https://aka.ms/vsls-linux-prereq-script \
    && /bin/bash vsls-linux-prereq-script.sh true false false \
    && rm vsls-linux-prereq-script.sh \
    #
    # Build git 2.27.0 from source
    && apt-get install -y gettext \
    && curl -sL https://github.com/git/git/archive/v2.27.0.tar.gz | tar -xzC /tmp \
    && (cd /tmp/git-2.27.0 && make -s prefix=/usr/local all && make -s prefix=/usr/local install) \
    && rm -rf /tmp/git-2.27.0 \
    #
    # Install Git LFS
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && apt-get install -yq git-lfs \
    && git lfs install \
    #
    # Install PowerShell
    && curl -s https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list \
    && apt-get update -yq \
    && apt-get install -yq powershell \
    #
    # Install Azure CLI
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && apt-get update \
    && apt-get install -y azure-cli \
    #
    # Install kubectl
    && curl -sSL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    #
    # Install Helm
    && curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash - \
    #
    # Setup codespace user
    && { echo && echo "PATH=${EXTRA_PATHS_OVERRIDES}:\$PATH:${USER_EXTRA_PATHS}" ; } | tee -a /etc/bash.bashrc >> /etc/skel/.bashrc \
    && { echo && echo $BASH_PROMPT ; } | tee -a /etc/bash.bashrc >> /etc/skel/.bashrc \
    && printf "$FISH_PROMPT" >> /etc/fish/conf.d/fish_prompt.fish \
    && { echo && echo $ZSH_PROMPT ; } | tee -a /etc/zsh/zshrc >> /etc/skel/.zshrc \
    && useradd --create-home --shell /bin/bash codespace \
    && mkdir -p /etc/sudoers.d \
    && echo "codespace ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd \
    && echo "Defaults secure_path=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin:${EXTRA_PATHS}\"" >> /etc/sudoers.d/securepath \
    && sudo -u codespace mkdir /home/codespace/.vsonline \
    && groupadd -g 800 docker \
    && usermod -a -G docker codespace \
    #
    # Setup .NET Core
    # Hack to get dotnet core sdks in the right place - Oryx images do not put dotnet on the path because it will break AppService.
    # The following script will put the dotnet's at /home/codespace/.dotnet folder where dotnet will look by default.
    && mv /tmp/codespace/symlinkDotNetCore.sh /home/codespace/symlinkDotNetCore.sh \
    && sudo -u codespace /bin/bash /home/codespace/symlinkDotNetCore.sh 2>&1 \
    && rm /home/codespace/symlinkDotNetCore.sh \
    #
    # Setup Node.js
    && sudo -u codespace npm config set prefix /home/codespace/.npm-global \
    && npm config -g set prefix /home/codespace/.npm-global \
    #
    # Install nvm (popular Node.js version-management tool)
    && sudo -u codespace curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | sudo -u codespace bash 2>&1 \
    && rm -rf /home/codespace/.nvm/.git \
    # 
    # Install nvs (alternate cross-platform Node.js version-management tool)
    && sudo -u codespace git clone -b v1.5.4 -c advice.detachedHead=false --depth 1 https://github.com/jasongin/nvs ${NVS_HOME} 2>&1 \
    && sudo -u codespace /bin/bash ${NVS_HOME}/nvs.sh install \
    && rm -rf ${NVS_HOME}/.git \
    #
    # Clear the nvs cache and link to an existing node binary to reduce the size of the image.
    && rm ${NVS_HOME}/cache/* \
    && sudo -u codespace ln -s /opt/nodejs/10.17.0/bin/node ${NVS_HOME}/cache/node \
    && sed -i "s/node\/[0-9.]\+/node\/10.17.0/" ${NVS_HOME}/defaults.json \
    #
    # Remove 'imagemagick imagemagick-6-common' due to http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-10131
    && apt-get purge -y imagemagick imagemagick-6-common \
    #
    # Configure VSCode as the default editor for git commits
    && sudo -u codespace mkdir -p /home/codespace/.local/bin \
    && install -o codespace -g codespace -m 755 /tmp/codespace/git-ed.sh /home/codespace/.local/bin/git-ed.sh \
    && sudo -u codespace git config --global core.editor "/home/codespace/.local/bin/git-ed.sh" \
    #
    # Alias code-insiders to code for easy terminal file editing
    && echo $'\nif [[ $(which code-insiders) && ! $(which code) ]]; then alias code=code-insiders; fi' >> /home/codespace/.bashrc \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y

USER codespace
