FROM alpine:latest
# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apk add --no-cache\
    bash \
    curl \
    git \
    openssh-client \
    sudo \
    && rm -rf /var/lib/apt/lists/*
RUN addgroup -g ${USER_GID} ${USERNAME} && \
    adduser -s /bin/ash -u ${USER_UID} -D -G ${USERNAME} ${USERNAME} && \
    echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME}&& \
    chmod 0440 /etc/sudoers.d/${USERNAME}
WORKDIR /src
ENTRYPOINT [ "/usr/bin/bash" ]
