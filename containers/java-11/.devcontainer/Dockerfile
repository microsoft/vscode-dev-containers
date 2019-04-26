#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM maven:3-jdk-11

# Copy endpoint specific user settings into container to specify Java path
COPY settings.vscode.json /root/.vscode-remote/data/Machine/settings.json

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

# Verify git, needed tools installed
RUN apt-get -y install git procps curl

# Install Gradle
ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 5.4
ARG GRADLE_DOWNLOAD_SHA256=c8c17574245ecee9ed7fe4f6b593b696d1692d1adbfef425bef9b333e3a0e8de
RUN curl -sSL --output gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln -s "${GRADLE_HOME}/bin/gradlec" /usr/bin/gradle

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog
