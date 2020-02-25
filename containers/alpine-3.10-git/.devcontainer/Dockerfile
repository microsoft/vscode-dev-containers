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

# Set to false to skip installing zsh and Oh My ZSH!
ARG INSTALL_ZSH="true"

# Location and expected SHA for common setup script - SHA generated on release
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.104.0/script-library/common-alpine.sh"
ARG COMMON_SCRIPT_SHA="acb22932d06ab7ea9e196dfa3537d55c7d47ea815bfb93581790297cc9e2173b"

# Install git, bash, dependencies, and add a non-root user
RUN apk update \
    && apk add --no-cache wget coreutils ca-certificates \
    #
    # Verify git, common tools / libs installed, add/modify non-root user, optionally install zsh
    && wget -q -O /tmp/common-setup.sh $COMMON_SCRIPT_SOURCE \
    && if [ "$COMMON_SCRIPT_SHA" != "dev-mode" ]; then echo "$COMMON_SCRIPT_SHA /tmp/common-setup.sh" | sha256sum -c - ; fi \
    && /bin/ash /tmp/common-setup.sh "$INSTALL_ZSH" "$USERNAME" "$USER_UID" "$USER_GID" \
    && rm /tmp/common-setup.sh
