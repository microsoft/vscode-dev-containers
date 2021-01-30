#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
FROM mcr.microsoft.com/oryx/build:vso-20200706.2 as kitchensink

ARG USERNAME=codespace
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Default to bash shell (other shells available at /usr/bin/fish and /usr/bin/zsh)
ENV SHELL=/bin/bash \
    ORYX_ENV_TYPE=vsonline-present \
    DOTNET_ROOT="/home/${USERNAME}/.dotnet" \ 
    NVM_SYMLINK_CURRENT=true \
    NVM_DIR="/home/${USERNAME}/.nvm" \
    NVS_HOME="/home/${USERNAME}/.nvs" \
    PIPX_HOME="/usr/local/py-utils" \
    PIPX_BIN_DIR="/usr/local/py-utils/bin" \
    RVM_PATH="/usr/local/rvm" \
    GOROOT="/usr/local/go" \
    GOPATH="/go" \
    CARGO_HOME="/usr/local/cargo" \
    RUSTUP_HOME="/usr/local/rustup" \
    SDKMAN_DIR="/usr/local/sdkman"
ENV PATH="${NVM_DIR}/current/bin:${DOTNET_ROOT}/tools:${SDKMAN_DIR}/bin:${SDKMAN_DIR}/candidates/java/current/bin:${SDKMAN_DIR}/candidates/gradle/current/bin:${SDKMAN_DIR}/candidates/maven/current/bin:${CARGO_HOME}/bin:${GOROOT}/bin:${GOPATH}/bin:${PATH}:${PIPX_BIN_DIR}"

# Install needed utilities and setup non-root user. Use a separate RUN statement to add your own dependencies.
COPY library-scripts/azcli-debian.sh library-scripts/common-debian.sh library-scripts/git-lfs-debian.sh library-scripts/github-debian.sh \
    library-scripts/kubectl-helm-debian.sh library-scripts/sshd-debian.sh setup-user.sh /tmp/scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    # Remove buster list to avoid unexpected errors given base image is stretch
    && rm /etc/apt/sources.list.d/buster.list \
    # Run common script and setup user
    && bash /tmp/scripts/common-debian.sh "true" "${USERNAME}" "${USER_UID}" "${USER_GID}" "true" "true" \
    && bash /tmp/scripts/setup-user.sh "${USERNAME}" "${PATH}" \
    # Upgrade git to avoid security issue
    && apt-get upgrade -yq git \
    # Remove 'imagemagick imagemagick-6-common' due to http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-10131
    && apt-get purge -y imagemagick imagemagick-6-common \
    # Verify expected build and debug tools are present
    && apt-get -y install build-essential cmake cppcheck valgrind clang lldb llvm gdb \
    # Install tools and shells not in common script
    && apt-get install -yq vim xtail software-properties-common libsecret-1-dev \
    && bash /tmp/scripts/sshd-debian.sh \
    && bash /tmp/scripts/git-lfs-debian.sh \
    && bash /tmp/scripts/github-debian.sh \
    && bash /tmp/scripts/azcli-debian.sh \
    && bash /tmp/scripts/kubectl-helm-debian.sh \
    # Clean up
    && rm -rf /tmp/scripts/ && apt-get autoremove -y && apt-get clean -y

# Build latest git from source
COPY library-scripts/git-from-src-debian.sh /tmp/scripts/
RUN bash /tmp/scripts/git-from-src-debian.sh "latest" \
    && apt-get clean -y && rm -rf /tmp/scripts

# Install PowerShell and setup .NET Core
COPY symlinkDotNetCore.sh /home/${USERNAME}/symlinkDotNetCore.sh
COPY library-scripts/powershell-debian.sh /tmp/scripts/
RUN bash /tmp/scripts/powershell-debian.sh \
    # Hack to get dotnet core sdks in the right place - Oryx images do not put dotnet on the path because it will break AppService.
    # The following script will put the dotnet's at /home/codespace/.dotnet folder where dotnet will look by default.
    && sudo -u ${USERNAME} /bin/bash /home/${USERNAME}/symlinkDotNetCore.sh 2>&1 \
    && apt-get clean -y && rm -rf /home/${USERNAME}/symlinkDotNetCore.sh /tmp/scripts/

# Setup Node.js, install NVM and NVS
COPY library-scripts/node-debian.sh /tmp/scripts/
RUN bash /tmp/scripts/node-debian.sh "${NVM_DIR}" "none" "${USERNAME}" \
    && (cd ${NVM_DIR} && git remote get-url origin && echo $(git log -n 1 --pretty=format:%H -- .)) > ${NVM_DIR}/.git-remote-and-commit \
    # Install nvs (alternate cross-platform Node.js version-management tool)
    && sudo -u ${USERNAME} git clone -c advice.detachedHead=false --depth 1 https://github.com/jasongin/nvs ${NVS_HOME} 2>&1 \
    && (cd ${NVS_HOME} && git remote get-url origin && echo $(git log -n 1 --pretty=format:%H -- .)) > ${NVS_HOME}/.git-remote-and-commit \
    && sudo -u ${USERNAME} bash ${NVS_HOME}/nvs.sh install \
    && rm ${NVS_HOME}/cache/* \
    # Set npm global location
    && sudo -u ${USERNAME} npm config set prefix /home/${USERNAME}/.npm-global \
    && npm config -g set prefix /root/.npm-global \
    # Clean up
    && rm -rf ${NVM_DIR}/.git ${NVS_HOME}/.git /tmp/scripts/

# Install OpenJDK 8, latest Java LTS (11), gradle, maven
COPY library-scripts/java-debian.sh library-scripts/maven-debian.sh library-scripts/gradle-debian.sh /tmp/scripts/
RUN bash /tmp/scripts/java-debian.sh "lts" "${SDKMAN_DIR}" "${USERNAME}" "true" \
    && bash /tmp/scripts/gradle-debian.sh "latest" "${SDKMAN_DIR}" "${USERNAME}" "true" \
    && bash /tmp/scripts/maven-debian.sh "latest" "${SDKMAN_DIR}" "${USERNAME}" "true" \
    && echo "Installing JDK 8..." \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -yq openjdk-8-jdk \
    && apt-get clean -y && rm -rf /tmp/scripts

# Install Rust
COPY library-scripts/rust-debian.sh /tmp/scripts/
RUN bash /tmp/scripts/rust-debian.sh "${CARGO_HOME}" "${RUSTUP_HOME}" "${USERNAME}" "true" \
    && apt-get clean -y && rm -rf /tmp/scripts

# Install Go
COPY library-scripts/go-debian.sh /tmp/scripts/
RUN bash /tmp/scripts/go-debian.sh "latest" "${GOROOT}" "${GOPATH}" "${USERNAME}" \
    && apt-get clean -y && rm -rf /tmp/scripts

# Install Python tools
COPY library-scripts/python-debian.sh /tmp/scripts/
RUN bash /tmp/scripts/python-debian.sh "none" "/opt/python/stable" "${PIPX_HOME}" "${USERNAME}" "true" \ 
    && apt-get clean -y && rm -rf /tmp/scripts

# Install xdebug, link composer
RUN yes | pecl install xdebug \
    && export PHP_LOCATION=$(dirname $(dirname $(which php))) \
    && echo "zend_extension=$(find ${PHP_LOCATION}/lib/php/extensions/ -name xdebug.so)" > ${PHP_LOCATION}/ini/conf.d/xdebug.ini \
    && echo "xdebug.mode = debug" >> ${PHP_LOCATION}/ini/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request = yes" >> ${PHP_LOCATION}/ini/conf.d/xdebug.ini \
    && echo "xdebug.client_port = 9000" >> ${PHP_LOCATION}/ini/conf.d/xdebug.ini \
    && rm -rf /tmp/pear \
    && ln -s $(which composer.phar) /usr/local/bin/composer

# Install rvm, Ruby, base gems
COPY library-scripts/ruby-debian.sh /tmp/scripts/
RUN bash /tmp/scripts/ruby-debian.sh "2.7.2" "${USERNAME}" "true" \
    && apt-get clean -y && rm -rf /tmp/scripts

# Install Moby CLI
COPY library-scripts/docker-debian.sh /tmp/scripts/
RUN bash /tmp/scripts/docker-debian.sh "true" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}" "true" \
    && rm -rf /tmp/scripts && apt-get clean -y

# Fire Docker script if needed along with Oryx's benv
ENTRYPOINT [ "/usr/local/share/docker-init.sh", "/usr/local/share/ssh-init.sh" ,"benv" ]
CMD [ "sleep", "infinity" ]

# [Optional] Install debugger for development of Codespaces - Not in resulting image by default
ARG DeveloperBuild
RUN if [ -z $DeveloperBuild ]; then \
        echo "not including debugger" ; \
    else \
        curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg ; \
    fi

USER ${USERNAME}
