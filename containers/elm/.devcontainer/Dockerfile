FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:12

# Configuring Elm version
ARG ELM_VERSION=latest-0.19.1
ARG ELM_TEST_VERSION=latest-0.19.1
ARG ELM_FORMAT_VERSION=latest-0.19.1

# This Dockerfile adds a non-root user with sudo access. Update the “remoteUser” property in
# devcontainer.json to use it. More info: https://aka.ms/vscode-remote/containers/non-root-user.
ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install elm, elm-test and elm-format
RUN export DEBIAN_FRONTEND=noninteractive \
    && sudo -u ${USERNAME} npm install --global \
    elm@${ELM_VERSION} \
    elm-test@${ELM_TEST_VERSION} \
    elm-format@${ELM_FORMAT_VERSION} \
    #
    # [Optional] Update UID/GID if needed
    && if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \
        groupmod --gid $USER_GID $USERNAME \
        && usermod --uid $USER_UID --gid $USER_GID $USERNAME \
        && chown -R $USER_UID:$USER_GID /home/$USERNAME; \
    fi
