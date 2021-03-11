# Update VARIANT in devcontainer.json to pick a Dart version
ARG VARIANT=2
FROM google/dart:${VARIANT}

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Add bin location to path
ENV PUB_CACHE="/usr/local/share/pub-cache"
ENV PATH="${PUB_CACHE}/bin:${PATH}"
RUN if ! cat /etc/group | grep -e "^pub-cache:" > /dev/null 2>&1; then groupadd -r pub-cache; fi \
    && usermod -a -G pub-cache ${USERNAME} \
    && umask 0002 \
    && mkdir -p ${PUB_CACHE} \
    && chown :pub-cache ${PUB_CACHE} \
    && sed -i -e "s/export PATH=/export PATH=\/usr\/local\/share\/pub-cache:/" /etc/profile.d/00-restore-env.sh

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>