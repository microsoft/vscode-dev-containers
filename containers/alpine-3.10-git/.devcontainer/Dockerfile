#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
FROM alpine:3.10

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Options for common package install script - SHA updated on release
ARG INSTALL_ZSH="true"
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/common-alpine.sh"
ARG COMMON_SCRIPT_SHA="dev-mode"

# Install git, bash, dependencies, and add a non-root user
RUN apk update \
    #
    # Verify git, common tools / libs installed, add/modify non-root user, optionally install zsh
    && apk add --no-cache curl ca-certificates \
    && curl -sSL  ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
    && if [ "$COMMON_SCRIPT_SHA" != "dev-mode" ]; then echo "$COMMON_SCRIPT_SHA */tmp/common-setup.sh" | sha256sum -c - ; fi \
    && /bin/ash /tmp/common-setup.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" \
    && rm /tmp/common-setup.sh
