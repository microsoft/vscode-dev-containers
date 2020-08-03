# Update the VARIANT arg in devcontainer.json to pick a Java version >= 11
ARG VARIANT=11
FROM openjdk:${VARIANT}-jdk-buster

# Options for setup script
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="false"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# [Optional] Install Maven
ARG INSTALL_MAVEN="false"
ARG MAVEN_VERSION=3.6.3
ARG MAVEN_DOWNLOAD_SHA="dev-mode"
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
ARG INSTALL_GRADLE="false"
ARG GRADLE_VERSION=5.4.1
ARG GRADLE_DOWNLOAD_SHA="dev-mode"
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

# [Optional] Install Node.js for use with web applications - update the INSTALL_NODE arg in devcontainer.json to enable.
ARG INSTALL_NODE="false"
ARG NODE_VERSION="lts/*"
ENV NVM_DIR=/usr/local/share/nvm \
    NVM_SYMLINK_CURRENT=true \
    PATH=${NVM_DIR}/current/bin:${PATH}
COPY library-scripts/node-debian.sh /tmp/library-scripts/
RUN if [ "$INSTALL_NODE" = "true" ]; then \
        /bin/bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}" \
        && apt-get clean -y && rm -rf /var/lib/apt/lists/*; \
    fi \
    && rm -rf /tmp/library-scripts

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>