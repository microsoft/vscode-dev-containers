# Find the Dockerfile for mcr.microsoft.com/azure-functions/java:3.0-java8-core-tools at this URL
# https://github.com/Azure/azure-functions-docker/blob/dev/host/3.0/buster/amd64/java/java8/java8-core-tools.Dockerfile
FROM mcr.microsoft.com/azure-functions/java:3.0-java11-core-tools

RUN apt-get -qq update && \
    apt-get install -y software-properties-common && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9 && \
    apt-add-repository "deb http://repos.azulsystems.com/debian stable main" && \
    apt-get -qq update && \
    apt-get -qq -y dist-upgrade && \
    apt-get -qq -y --no-install-recommends install zulu-8=8.46.0.19 && \
    rm -rf /var/lib/apt/lists/*

# Uncomment following lines If you want to enable Development Container Script
# For more details https://github.com/microsoft/vscode-dev-containers/tree/main/script-library

# Avoid warnings by switching to noninteractive
# ENV DEBIAN_FRONTEND=noninteractive

# # Comment out these lines if you want to use zsh.

# ARG INSTALL_ZSH=true
# ARG USERNAME=vscode
# ARG USER_UID=1000
# ARG USER_GID=$USER_UID

# RUN apt-get update && curl -ssL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh -o /tmp/common-script.sh \
#     && /bin/bash /tmp/common-script.sh "$INSTALL_ZSH" "$USERNAME" "$USER_UID" "$USER_GID" \
#     && rm /tmp/common-script.sh 