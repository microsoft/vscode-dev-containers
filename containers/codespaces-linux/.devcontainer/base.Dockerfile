#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
FROM mcr.microsoft.com/oryx/build:vso-focal-20201110.1 as kitchensink

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
ENV PATH="${NVM_DIR}/current/bin:${DOTNET_ROOT}/tools:${SDKMAN_DIR}/bin:${SDKMAN_DIR}/candidates/gradle/current/bin:/opt/maven/lts:${CARGO_HOME}/bin:${GOROOT}/bin:${GOPATH}/bin:${PATH}:${PIPX_BIN_DIR}"

# Install needed utilities and setup non-root user. Use a separate RUN statement to add your own dependencies.
COPY library-scripts/azcli-debian.sh library-scripts/common-debian.sh library-scripts/git-lfs-debian.sh library-scripts/github-debian.sh \
    library-scripts/kubectl-helm-debian.sh library-scripts/sshd-debian.sh setup-user.sh /tmp/scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    # Run common script and setup user
    && bash /tmp/scripts/common-debian.sh "true" "${USERNAME}" "${USER_UID}" "${USER_GID}" "false" "true" \
    && bash /tmp/scripts/setup-user.sh "${USERNAME}" "${PATH}" \
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

# Install rvm, base gems
COPY library-scripts/ruby-debian.sh /tmp/scripts/
RUN chown -R ${USERNAME} /opt/ruby/*/lib /opt/ruby/*/bin \
    && bash /tmp/scripts/ruby-debian.sh "none" "${USERNAME}" "true" "true" \
    && apt-get clean -y && rm -rf /tmp/scripts

# Build latest git from source
COPY library-scripts/git-from-src-debian.sh /tmp/scripts/
RUN bash /tmp/scripts/git-from-src-debian.sh "latest" \
    && apt-get clean -y && rm -rf /tmp/scripts

# Install PowerShell and setup .NET Core - PowerShell does not have a native package for Ubuntu 20.04, so use .net to do it
COPY symlinkDotNetCore.sh /home/${USERNAME}/symlinkDotNetCore.sh
COPY library-scripts/powershell-debian.sh /tmp/scripts/
RUN su ${USERNAME} -c 'bash /home/${USERNAME}/symlinkDotNetCore.sh' 2>&1 \
    #TODO: Switch back to powershell-debian.sh once 7.1 GA is released
    && su ${USERNAME} -c '/opt/dotnet/lts/dotnet tool install -g powershell' \
    # && bash /tmp/scripts/powershell-debian.sh \
    #
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

# Install OpenJDK 8, SDKMAN, gradle
COPY library-scripts/gradle-debian.sh /tmp/scripts/
RUN bash /tmp/scripts/gradle-debian.sh "latest" "${SDKMAN_DIR}" "${USERNAME}" "true" \
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
#RUN bash /tmp/scripts/python-debian.sh "none" "/opt/python/stable" "${PIPX_HOME}" "${USERNAME}" "true" \
# TODO: Remove workaround
RUN apt-get update && apt-get -y install python3-venv \
    && bash /tmp/scripts/python-debian.sh "none" "/usr" "${PIPX_HOME}" "${USERNAME}" "true" \
    && apt-get clean -y && rm -rf /tmp/scripts

# Install xdebug, link composer
RUN yes | pecl install xdebug \
    && export PHP_LOCATION=$(dirname $(dirname $(which php))) \
    && echo "zend_extension=$(find ${PHP_LOCATION}/lib/php/extensions/ -name xdebug.so)" > ${PHP_LOCATION}/ini/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> ${PHP_LOCATION}/ini/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=on" >>  ${PHP_LOCATION}/ini/conf.d/xdebug.ini \
    && rm -rf /tmp/pear \
    && ln -s $(which composer.phar) /usr/local/bin/composer

# [Option] Install Docker CLI
ARG INSTALL_DOCKER="false"
COPY library-scripts/docker-debian.sh /tmp/scripts/
RUN if [ "${INSTALL_DOCKER}" = "true" ]; then \
        bash /tmp/scripts/docker-debian.sh "true" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}"; \
    else \
        echo '#!/bin/bash\nexec "$@"' > /usr/local/share/docker-init.sh && chmod +x /usr/local/share/docker-init.sh; \
    fi \
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
