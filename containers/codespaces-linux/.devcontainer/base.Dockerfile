#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
FROM mcr.microsoft.com/oryx/build:vso-focal-20210319.1 as kitchensink

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
    NPM_GLOBAL="/home/${USERNAME}/.npm-global" \
    PIPX_HOME="/usr/local/py-utils" \
    PIPX_BIN_DIR="/usr/local/py-utils/bin" \
    RVM_PATH="/usr/local/rvm" \
    RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev" \ 
    GOROOT="/usr/local/go" \
    GOPATH="/go" \
    CARGO_HOME="/usr/local/cargo" \
    RUSTUP_HOME="/usr/local/rustup" \
    SDKMAN_DIR="/usr/local/sdkman"
ENV PATH="${ORIGINAL_PATH}:${NVM_DIR}/current/bin:${NPM_GLOBAL}/bin:${DOTNET_ROOT}:${DOTNET_ROOT}/tools:${SDKMAN_DIR}/bin:${SDKMAN_DIR}/candidates/gradle/current/bin:${SDKMAN_DIR}/java/current/bin:/opt/maven/lts:${CARGO_HOME}/bin:${GOROOT}/bin:${GOPATH}/bin:${PIPX_BIN_DIR}:/opt/conda/condabin:${ORYX_PATHS}"

# Install needed utilities and setup non-root user. Use a separate RUN statement to add your own dependencies.
COPY library-scripts/* setup-user.sh first-run-notice.txt /tmp/scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    # Restore man command
    && yes | unminimize 2>&1 \ 
    # Run common script and setup user
    && bash /tmp/scripts/common-debian.sh "true" "${USERNAME}" "${USER_UID}" "${USER_GID}" "true" "true" "true" \
    && bash /tmp/scripts/setup-user.sh "${USERNAME}" "${PATH}" \
    # Change owner of opt contents since Oryx can dynamically install and will run as "codespace"
    && chown codespace /opt/* \
    # Verify expected build and debug tools are present
    && apt-get -y install build-essential cmake cppcheck valgrind clang lldb llvm gdb python3-dev \
    # Install tools and shells not in common script
    && apt-get install -yq vim vim-doc xtail software-properties-common libsecret-1-dev \
    # Install additional tools (useful for 'puppeteer' project)
    && apt-get install -y --no-install-recommends libnss3 libnspr4 libatk-bridge2.0-0 libatk1.0-0 libx11-6 libpangocairo-1.0-0 \
                                                  libx11-xcb1 libcups2 libxcomposite1 libxdamage1 libxfixes3 libpango-1.0-0 libgbm1 libgtk-3-0 \
    && bash /tmp/scripts/sshd-debian.sh \
    && bash /tmp/scripts/git-lfs-debian.sh \
    && bash /tmp/scripts/github-debian.sh \
    && bash /tmp/scripts/azcli-debian.sh \
    && bash /tmp/scripts/kubectl-helm-debian.sh \
    # Install Moby CLI and Engine
    && bash /tmp/scripts/docker-in-docker-debian.sh "true" "${USERNAME}" "true" \
    # Build latest git from source
    && bash /tmp/scripts/git-from-src-debian.sh "latest" \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y \
    # Move first run notice to right spot
    && mkdir -p /usr/local/etc/vscode-dev-containers/ \
    && mv -f /tmp/scripts/first-run-notice.txt /usr/local/etc/vscode-dev-containers/

# Install Python, PHP, Ruby utilities
RUN bash /tmp/scripts/python-debian.sh "none" "/opt/python/latest" "${PIPX_HOME}" "${USERNAME}" "true" \
    # Install rvm, rbenv, base gems
    && chown -R ${USERNAME} /opt/ruby/*/lib /opt/ruby/*/bin \
    && bash /tmp/scripts/ruby-debian.sh "none" "${USERNAME}" "true" "true" \
    # Install xdebug, link composer
    && yes | pecl install xdebug \
    && export PHP_LOCATION=$(dirname $(dirname $(which php))) \
    && echo "zend_extension=$(find ${PHP_LOCATION}/lib/php/extensions/ -name xdebug.so)" > ${PHP_LOCATION}/ini/conf.d/xdebug.ini \
    && echo "xdebug.mode = debug" >> ${PHP_LOCATION}/ini/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request = yes" >> ${PHP_LOCATION}/ini/conf.d/xdebug.ini \
    && echo "xdebug.client_port = 9000" >> ${PHP_LOCATION}/ini/conf.d/xdebug.ini \
    && rm -rf /tmp/pear \
    && ln -s $(which composer.phar) /usr/local/bin/composer \
    && apt-get clean -y

# Install PowerShell and setup .NET Core
COPY symlinkDotNetCore.sh /home/${USERNAME}/symlinkDotNetCore.sh
RUN su ${USERNAME} -c 'bash /home/${USERNAME}/symlinkDotNetCore.sh' 2>&1 \
    && bash /tmp/scripts/powershell-debian.sh \
    && apt-get clean -y && rm -rf /home/${USERNAME}/symlinkDotNetCore.sh

# Setup Node.js, install NVM and NVS
RUN bash /tmp/scripts/node-debian.sh "${NVM_DIR}" "none" "${USERNAME}" \
    && (cd ${NVM_DIR} && git remote get-url origin && echo $(git log -n 1 --pretty=format:%H -- .)) > ${NVM_DIR}/.git-remote-and-commit \
    # Install nvs (alternate cross-platform Node.js version-management tool)
    && sudo -u ${USERNAME} git clone -c advice.detachedHead=false --depth 1 https://github.com/jasongin/nvs ${NVS_HOME} 2>&1 \
    && (cd ${NVS_HOME} && git remote get-url origin && echo $(git log -n 1 --pretty=format:%H -- .)) > ${NVS_HOME}/.git-remote-and-commit \
    && sudo -u ${USERNAME} bash ${NVS_HOME}/nvs.sh install \
    && rm ${NVS_HOME}/cache/* \
    # Set npm global location
    && sudo -u ${USERNAME} npm config set prefix ${NPM_GLOBAL} \
    && npm config -g set prefix ${NPM_GLOBAL} \
    # Clean up
    && rm -rf ${NVM_DIR}/.git ${NVS_HOME}/.git

# Install SDKMAN, OpenJDK8 (JDK 11 already present), gradle (maven already present)
RUN bash /tmp/scripts/gradle-debian.sh "latest" "${SDKMAN_DIR}" "${USERNAME}" "true" \
    && bash /tmp/scripts/java-debian.sh "8.0.275.hs-adpt" "${SDKMAN_DIR}" "${USERNAME}" "true" \
    && su ${USERNAME} -c ". ${SDKMAN_DIR}/bin/sdkman-init.sh \
        && sdk install java opt-java-11 /opt/java/11.0 \
        && sdk install java opt-java-lts /opt/java/lts \
        && sdk default java opt-java-lts"

# Install Rust, Go, remove scripts now that we're done with them
RUN bash /tmp/scripts/rust-debian.sh "${CARGO_HOME}" "${RUSTUP_HOME}" "${USERNAME}" "true" \
    && bash /tmp/scripts/go-debian.sh "latest" "${GOROOT}" "${GOPATH}" "${USERNAME}" \
    && apt-get clean -y && rm -rf /tmp/scripts

# Mount for docker-in-docker 
VOLUME [ "/var/lib/docker" ]

# Fire Docker/Moby script if needed along with Oryx's benv
ENTRYPOINT [ "/usr/local/share/docker-init.sh", "/usr/local/share/ssh-init.sh", "benv" ]
CMD [ "sleep", "infinity" ]

# [Optional] Install debugger for development of Codespaces - Not in resulting image by default
ARG DeveloperBuild
RUN if [ -z $DeveloperBuild ]; then \
        echo "not including debugger" ; \
    else \
        curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg ; \
    fi

USER ${USERNAME}
