# [Choice] Java version: 11, 15
ARG VARIANT=11
FROM openjdk:${VARIANT}-jdk-buster

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/common-debian.sh /tmp/library-scripts/
RUN bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    && if [ ! -d "/docker-java-home" ]; then ln -s "${JAVA_HOME}" /docker-java-home; fi \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# [Option] Install Maven
ARG INSTALL_MAVEN="false"
ARG MAVEN_VERSION=""
# [Option] Install Gradle
ARG INSTALL_GRADLE="false"
ARG GRADLE_VERSION=""
ENV SDKMAN_DIR="/usr/local/sdkman"
ENV PATH="${PATH}:${SDKMAN_DIR}/java/current/bin:${SDKMAN_DIR}/maven/current/bin:${SDKMAN_DIR}/gradle/current/bin"
COPY library-scripts/java-debian.sh library-scripts/maven-debian.sh library-scripts/gradle-debian.sh /tmp/library-scripts/
RUN bash /tmp/library-scripts/java-debian.sh "none" "${SDKMAN_DIR}" "${USERNAME}" "true" \
    && if [ "${INSTALL_MAVEN}" = "true" ]; then bash /tmp/library-scripts/maven-debian.sh "${MAVEN_VERSION:-latest}" "${SDKMAN_DIR}" ${USERNAME} "true"; fi \
    && if [ "${INSTALL_GRADLE}" = "true" ]; then bash /tmp/library-scripts/gradle-debian.sh "${GRADLE_VERSION:-latest}" "${SDKMAN_DIR}" ${USERNAME} "true"; fi \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# [Option] Install Node.js
ARG INSTALL_NODE="true"
ARG NODE_VERSION="none"
ENV NVM_DIR=/usr/local/share/nvm
ENV NVM_SYMLINK_CURRENT=true \
    PATH="${NVM_DIR}/current/bin:${PATH}"
COPY library-scripts/node-debian.sh /tmp/library-scripts/
RUN if [ "$INSTALL_NODE" = "true" ]; then bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}"; fi \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>