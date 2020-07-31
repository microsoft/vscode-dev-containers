# Update the VARIANT arg in devcontainer.json to pick a Java version >= 11
ARG VARIANT=11
FROM openjdk:${VARIANT}-jdk-buster

# Options
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="false"
ARG INSTALL_MAVEN="false"
ARG INSTALL_GRADLE="false"

# This Dockerfile adds a non-root user with sudo access. Update the “remoteUser” property in
# devcontainer.json to use it. More info: https://aka.ms/vscode-remote/containers/non-root-user.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Script sources and SHAs
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="dev-mode"
ARG MAVEN_VERSION=3.6.3
ARG MAVEN_DOWNLOAD_SHA="dev-mode"
ARG GRADLE_VERSION=5.4.1
ARG GRADLE_DOWNLOAD_SHA="dev-mode"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends curl ca-certificates 2>&1 \
    && curl -sSL  ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
    && ([ "${COMMON_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/common-setup.sh" | sha256sum -c -)) \
    && /bin/bash /tmp/common-setup.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/common-setup.sh 

# [Optional] Install Maven
ENV MAVEN_HOME /usr/share/maven \
    MAVEN_CONFIG /root/.m2
COPY maven-settings.xml /usr/share/maven/ref/
RUN if [ "${INSTALL_MAVEN}" = "true" ]; then \
        mkdir -p /usr/share/maven /usr/share/maven/ref \
        && curl -fsSL -o /tmp/apache-maven.tar.gz https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
        && ([ "${MAVEN_DOWNLOAD_SHA}" = "dev-mode" ] || echo "${MAVEN_DOWNLOAD_SHA} */tmp/apache-maven.tar.gz" | sha512sum -c - ) \
        && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
        && rm -f /tmp/apache-maven.tar.gz \
        && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn; \
    fi

# [Optional] Install Gradle
ENV GRADLE_HOME=/opt/gradle
RUN if [ "${INSTALL_GRADLE}" = "true" ]; then \
        curl -sSL --output gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
        && ([ "${GRADLE_DOWNLOAD_SHA}" = "dev-mode" ] || echo "${GRADLE_DOWNLOAD_SHA} *gradle.zip" | sha256sum --check - ) \
        && unzip gradle.zip \
        && rm gradle.zip \
        && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
        && ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle; \
    fi

# Allow for a consistant java home location for settings - image is changing over time
RUN if [ ! -d "/docker-java-home" ]; then ln -s "${JAVA_HOME}" /docker-java-home; fi

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>