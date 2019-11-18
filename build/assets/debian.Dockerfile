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

# [Optional] Update UID/GID if needed and install additional software
RUN if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \
        sudo groupmod 1000 --gid $USER_GID \
        && sudo usermod --uid $USER_UID --gid $USER_GID 1000 \
    fi

# ENV DEBIAN_FRONTEND=noninteractive
# RUN apt-get update \
#    #
#    ***************************************************************
#    * Add steps for installing any other needed dependencies here *
#    ***************************************************************
#    && sudo apt-get -y install --no-reccomends <your-package-name-here>
#    #
#    # Clean up
#    && sudo apt-get autoremove -y \
#    && sudo apt-get clean -y \
#    && sudo rm -rf /var/lib/apt/lists/*
# ENV DEBIAN_FRONTEND=

# Uncomment to default to non-root user
# USER $USER_UID

