# Update VARIANT in devcontainer.json to pick a Dart version
ARG VARIANT=2
FROM google/dart:${VARIANT}

# This Dockerfile adds a non-root user with sudo access. Update the “remoteUser” property in
# devcontainer.json to use it. More info: https://aka.ms/vscode-remote/containers/non-root-user.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Options for common setup script
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="false"
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.130.0/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="a6bfacc5c9c6c3706adc8788bf70182729767955b7a5509598ac205ce6847e1e"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends curl ca-certificates 2>&1 \
    && curl -sSL  ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
    && ([ "${COMMON_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/common-setup.sh" | sha256sum -c -)) \
    && /bin/bash /tmp/common-setup.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/common-setup.sh

# Add bin location to path
ENV PUB_CACHE="/usr/local/share/pub-cache"
ENV PATH="${PATH}:${PUB_CACHE}/bin"
RUN mkdir -p ${PUB_CACHE} \
    && chown ${USERNAME}:root ${PUB_CACHE} \
    && echo "if [ \"\$(stat -c '%U' ${PUB_CACHE})\" != \"${USERNAME}\" ]; then sudo chown -R ${USER_UID}:root ${PUB_CACHE}; fi" \
    | tee -a /root/.bashrc /root/.zshrc /home/${USERNAME}/.bashrc >> /home/${USERNAME}/.zshrc

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>