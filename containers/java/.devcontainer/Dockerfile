ARG VARIANT=11
FROM mcr.microsoft.com/vscode/devcontainers/java:${VARIANT}

# [Optional] Install a version of Node.js using nvm for front end dev
ARG INSTALL_NODE="true"
ARG NODE_VERSION="lts/*"
RUN if [ "${INSTALL_NODE}" = "true" ]; then su vscode -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# [Optional] Install Maven
ARG INSTALL_MAVEN="false"
ARG MAVEN_VERSION=3.6.3
ARG MAVEN_DOWNLOAD_SHA="no-check"
ENV MAVEN_HOME=/usr/local/share/maven
COPY library-scripts/maven-debian.sh /tmp/library-scripts/
RUN if [ "${INSTALL_MAVEN}" = "true" ]; then /bin/bash /tmp/library-scripts/maven-debian.sh ${MAVEN_VERSION} ${MAVEN_HOME} ${USERNAME} ${MAVEN_DOWNLOAD_SHA}; fi \
    && rm -f /tmp/library-scripts

# [Optional] Install Gradle
ARG INSTALL_GRADLE="false"
ARG GRADLE_VERSION=5.4.1
ARG GRADLE_DOWNLOAD_SHA="no-check"
ENV GRADLE_HOME=/usr/local/share/gradle
COPY library-scripts/gradle-debian.sh /tmp/library-scripts/
RUN if [ "${INSTALL_GRADLE}" = "true" ]; then /bin/bash /tmp/library-scripts/gradle-debian.sh ${GRADLE_VERSION} ${GRADLE_HOME} ${USERNAME} ${GRADLE_DOWNLOAD_SHA}; fi \
    && rm -f /tmp/library-scripts

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1