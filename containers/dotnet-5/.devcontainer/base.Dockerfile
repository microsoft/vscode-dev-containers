# [Choice] Ubuntu version: focal, bionic, latest
ARG VARIANT="focal"
# [Choice] Install ZSH shell
ARG INSTALL_ZSH="true"
# [Choice] Upgrade OS packages
ARG UPGRADE_PACKAGES="true"

FROM buildpack-deps:${VARIANT}-curl

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ENV SHELL="/bin/zsh" \
    DOTNET_ROOT="/usr/share/dotnet" \ 
    NVM_SYMLINK_CURRENT=true \
    NVM_DIR="/home/${USERNAME}/.nvm" \
    NVS_HOME="/home/${USERNAME}/.nvs" \
    GOROOT="/usr/local/go" \
    GOPATH="/go" \
    PATH="${NVM_DIR}/current/bin:/home/${USERNAME}/tools:${GOROOT}/bin:${GOPATH}/bin:${PATH}"

COPY library-scripts/*.sh /tmp/library-scripts/
COPY copy-kube-config.sh /usr/local/share/

RUN apt-get update \
    # Remove imagemagick CVE-2019-10131
    && apt-get purge -y imagemagick imagemagick-6-common \
    # Install common utils
    && bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    # Install Docker
    && bash /tmp/library-scripts/docker-debian.sh "true" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}" \
    # Install Github CLI 
    && bash /tmp/library-scripts/github-debian.sh \
    # Install Azure CLI
    && bash /tmp/library-scripts/azcli-debian.sh \
    # Install GO
    && bash /tmp/library-scripts/go-debian.sh \
    # Setup Node.js, install NVM and NVS
    && rm -rf /opt/yarn-* /usr/local/bin/yarn /usr/local/bin/yarnpkg \
    && bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "14" "${USERNAME}" \
    && (cd ${NVM_DIR} && git remote get-url origin && echo $(git log -n 1 --pretty=format:%H -- .)) > ${NVM_DIR}/.git-remote-and-commit \
    # Install nvs (alternate cross-platform Node.js version-management tool)
    && sudo -u ${USERNAME} git clone -c advice.detachedHead=false --depth 1 https://github.com/jasongin/nvs ${NVS_HOME} 2>&1 \
    && (cd ${NVS_HOME} && git remote get-url origin && echo $(git log -n 1 --pretty=format:%H -- .)) > ${NVS_HOME}/.git-remote-and-commit \
    && sudo -u ${USERNAME} bash ${NVS_HOME}/nvs.sh install \
    && rm ${NVS_HOME}/cache/* \    
    # Clean up NVM
    && rm -rf ${NVM_DIR}/.git ${NVS_HOME}/.git \
    # Install Kubernetes tools
    && curl -sSL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    # Install Helm
    && curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash - \
    # Script copies localhost's ~/.kube/config file into the container and swaps out 
    # localhost for host.docker.internal on bash/zsh start to keep them in sync.
    && chown ${USERNAME}:root /usr/local/share/copy-kube-config.sh \
    && echo "source /usr/local/share/copy-kube-config.sh" | tee -a /root/.bashrc /root/.zshrc /home/${USERNAME}/.bashrc >> /home/${USERNAME}/.zshrc \
    # Install .net 5
    && mkdir -p ${DOTNET_ROOT}/install \ 
    && curl -H 'Cache-Control: no-cache' -L https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb -o ${DOTNET_ROOT}/install/packages-microsoft-prod.deb \
    && dpkg -i ${DOTNET_ROOT}/install/packages-microsoft-prod.deb \
    && apt-get update && apt-get install -y --no-install-recommends dotnet-sdk-5.0 \
    && dotnet tool install -g powershell \
    && dotnet nuget locals --clear all \
    # Install vs debugger
    && curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg \
    # Cleanup
    && apt-get autoremove -y \ 
    && apt-get clean -y \
    && bash -c "rm -rf /dotnet-*.gz ~/${DOTNET_ROOT}/install /var/lib/apt/lists/* /tmp/library-scripts"
    
# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# Fire Docker script if needed along with Oryx's benv
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
