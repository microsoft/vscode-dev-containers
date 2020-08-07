# Update VARIANT in devcontainer.json to pick a Dart version
ARG VARIANT=2
FROM google/dart:${VARIANT}

# Options for setup script
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="false"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Add bin location to path
ENV PUB_CACHE="/usr/local/share/pub-cache"
ENV PATH="${PATH}:${PUB_CACHE}/bin"
RUN mkdir -p ${PUB_CACHE} \
    && chown ${USERNAME}:root ${PUB_CACHE} \
    && echo "if [ \"\$(stat -c '%U' ${PUB_CACHE})\" != \"${USERNAME}\" ]; then sudo chown -R ${USER_UID}:root ${PUB_CACHE}; fi" \
    | tee -a /root/.bashrc /root/.zshrc /home/${USERNAME}/.bashrc >> /home/${USERNAME}/.zshrc

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>