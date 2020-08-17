#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
FROM mcr.microsoft.com/oryx/build:vso-20200706.2 as kitchensink

# Default to bash shell (other shells available at /usr/bin/fish and /usr/bin/zsh)
ENV SHELL=/bin/bash \
    ORYX_ENV_TYPE=vsonline-present

# Install needed utilities and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=codespace
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG GITHUB_CLI_VERSION=0.11.0
COPY library-scripts/*.sh setup-user.sh /tmp/scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    # Remove buster list to avoid unexpected errors given base image is stretch
    && rm /etc/apt/sources.list.d/buster.list \
    # Run common script and setup user
    && bash /tmp/scripts/common-debian.sh "true" "${USERNAME}" "${USER_UID}" "${USER_GID}" "false" \
    && bash /tmp/scripts/setup-user.sh "${USERNAME}" \
    # Upgrade git to avoid security issue
    && apt-get upgrade -yq git \
    # Remove 'imagemagick imagemagick-6-common' due to http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-10131
    && apt-get purge -y imagemagick imagemagick-6-common \
    # Install tools and shells not in common script
    && apt-get install -yq vim xtail software-properties-common \
    && bash /tmp/scripts/gitlfs-debian.sh \
    && bash /tmp/scripts/ghcli-debian.sh ${GITHUB_CLI_VERSION}\
    && bash /tmp/scripts/azcli-debian.sh \
    && bash /tmp/scripts/kubectl-helm-debian.sh \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y

# Install PowerShell and setup .NET Core
ENV DOTNET_ROOT=/home/${USERNAME}/.dotnet
COPY symlinkDotNetCore.sh /home/${USERNAME}/symlinkDotNetCore.sh
RUN bash /tmp/scripts/powershell-debian.sh \
    # Hack to get dotnet core sdks in the right place - Oryx images do not put dotnet on the path because it will break AppService.
    # The following script will put the dotnet's at /home/codespace/.dotnet folder where dotnet will look by default.
    && sudo -u ${USERNAME} /bin/bash /home/${USERNAME}/symlinkDotNetCore.sh 2>&1 \
    && apt-get clean -y && rm /home/${USERNAME}/symlinkDotNetCore.sh

# Setup Node.js, install NVM and NVS
ARG NVS_HOME="/home/${USERNAME}/.nvs"
ENV NVM_DIR="/home/${USERNAME}/.nvm"
ENV NVM_SYMLINK_CURRENT=true \
    PATH=${NVM_DIR}/current/bin:${PATH}
RUN sudo -u ${USERNAME} npm config set prefix /home/${USERNAME}/.npm-global \
    && npm config -g set prefix /home/${USERNAME}/.npm-global \
    # Install nvm
    && bash /tmp/scripts/node-debian.sh "${NVM_DIR}" "none" "${USERNAME}" \
    # Install nvs (alternate cross-platform Node.js version-management tool)
    && sudo -u ${USERNAME} git clone -b v1.5.4 -c advice.detachedHead=false --depth 1 https://github.com/jasongin/nvs ${NVS_HOME} 2>&1 \
    && sudo -u ${USERNAME} /bin/bash ${NVS_HOME}/nvs.sh install \
    # Clear the nvs cache and link to an existing node binary to reduce the size of the image.
    && rm ${NVS_HOME}/cache/* \
    && sudo -u codespace ln -s /opt/nodejs/10.17.0/bin/node ${NVS_HOME}/cache/node \
    && sed -i "s/node\/[0-9.]\+/node\/10.17.0/" ${NVS_HOME}/defaults.json \
    # Clean up
    && rm -rf ${NVM_DIR}/.git ${NVS_HOME}/.git

# Install OpenJDK 8 and 11
RUN mkdir -p /opt/java/openjdk-11 \
    && echo "Downloading JDK 11..." \
    && curl -fsSL -o /tmp/openjdk11.tar.gz https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.8%2B10/OpenJDK11U-jdk_x64_linux_11.0.8_10.tar.gz \
    && echo "Installing JDK 11..." \
    && tar -xzf /tmp/openjdk11.tar.gz -C /opt/java/openjdk-11 --strip-components=1 \ 
    && chown -R ${USERNAME} /opt/java/openjdk-11 \
    && rm -f /tmp/openjdk11.tar.gz \
    && echo "Installing JDK 8..." \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -yq openjdk-8-jdk \
    && ln -s /opt/java/usr/lib/jvm/java-8-openjdk-amd64 /opt/java/openjdk-8 \
    && apt-get clean -y

# Install Rust
ENV CARGO_HOME="/usr/local/cargo" \
    RUSTUP_HOME="/usr/local/rustup"
ENV PATH="${PATH}:${CARGO_HOME}/bin"
RUN bash /tmp/scripts/rust-debian.sh \
    && apt-get clean -y

# [Optional] Install Docker - Not in resulting image by default
ARG INSTALL_DOCKER="false"
RUN if [ "${INSTALL_DOCKER}" = "true" ]; then \
        bash /tmp/scripts/docker-debian.sh "true" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}"; \
    else \
        echo '#!/bin/bash\n"$@"' > /usr/local/share/docker-init.sh && chmod +x /usr/local/share/docker-init.sh; \
    fi

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access to 
# the Docker socket if "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# [Optional] Install debugger for development of Codespaces - Not in resulting image by default
ARG DeveloperBuild
RUN if [ -z $DeveloperBuild ]; then \
    echo "not including debugger" ; \
else \
    curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg ; \
fi \
&& rm -rf /tmp/scripts

USER ${USERNAME}