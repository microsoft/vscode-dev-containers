
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Note: You can use any Debian/Ubuntu based image you want. 
FROM mcr.microsoft.com/vscode/devcontainers/base:debian-10

# Docker Compose version
ARG COMPOSE_VERSION=1.24.0

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Copy the initalization script used as an ENTRYPOINT into 
# the container and set related, configurable build ARGS
COPY ./docker-init.sh /usr/local/share/docker-init.sh
ARG ENABLE_NONROOT_DOCKER="true"
ARG SOURCE_SOCKET=/var/run/docker-host.sock
ARG TARGET_SOCKET=/var/run/docker.sock

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    # Verify common dependencies and utilities are installed
    && apt-get -y install --no-install-recommends apt-utils dialog git openssh-client less iproute2 procps 2>&1 \
    #
    # Install Docker CE CLI
    && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent lsb-release \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get -y install --no-install-recommends docker-ce-cli \
    #
    # Install Docker Compose
    && curl -sSL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    #
    # Create a non-root user to use if not already available - see https://aka.ms/vscode-remote/containers/non-root-user.
    && if [ $(getent passwd $USERNAME) ]; then \
        # If exists, see if we need to tweak the GID/UID
        if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \
            groupmod --gid $USER_GID $USERNAME \
            && usermod --uid $USER_UID --gid $USER_GID $USERNAME \
            && chown -R $USER_UID:$USER_GID /home/$USERNAME; \
        fi; \
    else \
        # Otherwise ccreate the non-root user
        groupadd --gid $USER_GID $USERNAME \
        && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
        # Add sudo support for the non-root user
        && apt-get install -y sudo \
        && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
        && chmod 0440 /etc/sudoers.d/$USERNAME; \
    fi \
    #
    # Default to root only access to the Docker socket, set up non-root init script
    && if [ "${SOURCE_SOCKET}" != "${TARGET_SOCKET}" ]; then \
        touch "${SOURCE_SOCKET}" \
        && ln -s "${SOURCE_SOCKET}" "${TARGET_SOCKET}"; \
    fi \
    && apt-get -y install socat \
    && chmod +x /usr/local/share/docker-init.sh \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access to 
# the Docker socket if "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENV DOCKER_INIT_ENABLE_NONROOT="${ENABLE_NONROOT_DOCKER}"
ENV DOCKER_INIT_SOURCE_SOCKET="${SOURCE_SOCKET}"
ENV DOCKER_INIT_TARGET_SOCKET="${TARGET_SOCKET}"
ENV DOCKER_INIT_NONROOT_USER="${USERNAME}"
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
