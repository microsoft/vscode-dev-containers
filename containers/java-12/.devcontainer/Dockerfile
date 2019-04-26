#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM maven:3-jdk-12

# Add a setting to disable the out of date git warning. Unfortunatley, openJDK 
# Docker images use Oracle SE Linux which has an outdated version of git (<2.0).
# Also specifies correct Java path.
COPY settings.vscode.json /root/.vscode-remote/data/Machine/settings.json

# Verify git, needed tools installed
RUN yum install -y git curl procps unzip

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

# Clean yum cache
RUN yum clean all
