#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:12

# The node image includes a non-root user with sudo access. Use the 
# "remoteUser" property in devcontainer.json to use it. On Linux, update 
# these values to ensure the container user's UID/GID matches your local values.
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# [Optional] Update UID/GID if needed
RUN if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \
        groupmod --gid $USER_GID $USERNAME \
        && usermod --uid $USER_UID --gid $USER_GID $USERNAME \
        && chmod -R $USER_UID:$USER_GID /home/$USERNAME; \
    fi

# *************************************************************
# * Uncomment this section to use RUN instructions to install *
# * any needed dependencies after executing "apt-get update". *
# * See https://docs.docker.com/engine/reference/builder/#run *
# *************************************************************
# ENV DEBIAN_FRONTEND=noninteractive
# RUN apt-get update \
#    && apt-get -y install --no-reccomends <your-package-list-here> \
#    #
#    # Clean up
#    && apt-get autoremove -y \
#    && apt-get clean -y \
#    && rm -rf /var/lib/apt/lists/*
# ENV DEBIAN_FRONTEND=dialog

# Uncomment to default to non-root user
# USER $USER_UID
