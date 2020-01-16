#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM REPLACE-ME

# The image referenced above includes a non-root user with sudo access. Add 
# the "remoteUser" property to devcontainer.json to use it. On Linux, the container 
# user's GID/UIDs will be updated to match your local UID/GID when using the image
# or dockerFile property. Update USER_UID/USER_GID below if you are using the
# dockerComposeFile property or want the image itself to start with different ID
# values. See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# [Optional] Update UID/GID if needed
RUN if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \
        apk add --no-cache shadow \
        && USERNAME=$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd) \
        && groupmod --gid $USER_GID $USERNAME \
        && usermod --uid $USER_UID --gid $USER_GID $USERNAME \
        && chown -R $USER_UID:$USER_GID /home/$USERNAME; \
    fi

# ************************************************************************
# * Uncomment this section to use RUN to install other dependencies.     *
# * Note that Alpine uses "apk" instead of "apt-get" like Debian/Ubuntu. *
# * See https://aka.ms/vscode-remote/containers/dockerfile-run           *
# ************************************************************************
# RUN apk update \
#     && apk add --no-cache <your-package-list-here>

# Uncomment to default to non-root user
# USER $USER_UID
