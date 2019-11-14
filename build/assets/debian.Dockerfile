#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM REPLACE-ME

# This image comes with a base non-root user with sudo access. However, for Linux, 
# this user's GID/UID must match your local user UID/GID to avoid permission issues 
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See 
# https://aka.ms/vscode-remote/containers/non-root-user.
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# [Optional] Update UID/GID if needed and install additional software
RUN if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \
        if [ "$USER_GID" != "1000" ]; then sudo groupmod 1000 --gid $USER_GID; fi \
        && if [ "$USER_UID" != "1000" ]; then sudo usermod --uid $USER_UID node; fi; \
    fi \
    #
    # ***************************************************************
    # * Add steps for installing any other needed dependencies here *
    # ***************************************************************
    #
    # Clean up
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

# Uncomment to default to non-root user
# USER $USER_UID

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=
