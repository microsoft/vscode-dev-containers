#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM openjdk:11-jdk

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Options for common package install script
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="true"
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.128.0/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="a6bfacc5c9c6c3706adc8788bf70182729767955b7a5509598ac205ce6847e1e"

# Configure apt
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    #
    # Verify git, common tools / libs installed, add/modify non-root user, optionally install zsh
    && apt-get -y install --no-install-recommends curl ca-certificates 2>&1 \
    && curl -sSL  ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
    && ([ "${COMMON_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/common-setup.sh" | sha256sum -c -)) \
    && /bin/bash /tmp/common-setup.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    && rm /tmp/common-setup.sh

#-------------------Uncomment the following steps to install Maven CLI Tools----------------------------------
# ARG MAVEN_VERSION=3.6.3
# ARG MAVEN_SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
# RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && curl -fsSL -o /tmp/apache-maven.tar.gz https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
#     && echo "${MAVEN_SHA} /tmp/apache-maven.tar.gz" | sha512sum -c - \
#     && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
#     && rm -f /tmp/apache-maven.tar.gz \
#     && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
# COPY maven-settings.xml /usr/share/maven/ref/
# ENV MAVEN_HOME /usr/share/maven
# ENV MAVEN_CONFIG /root/.m2
#-------------------------------------------------------------------------------------------------------------

#-------------------Uncomment the following steps to install Gradle CLI Tools---------------------------------
# ENV GRADLE_HOME /opt/gradle
# ENV GRADLE_VERSION 5.4.1
# ARG GRADLE_DOWNLOAD_SHA256=7bdbad1e4f54f13c8a78abc00c26d44dd8709d4aedb704d913fb1bb78ac025dc
# RUN curl -sSL --output gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
#     && unzip gradle.zip \
#     && rm gradle.zip \
#     && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
#     && ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle
#-------------------------------------------------------------------------------------------------------------

# Clean up
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Allow for a consistant java home location for settings - image is changing over time
RUN if [ ! -d "/docker-java-home" ]; then ln -s "${JAVA_HOME}" /docker-java-home; fi
