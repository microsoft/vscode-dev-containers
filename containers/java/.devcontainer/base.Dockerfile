# This base.Dockerfile uses separate build arguments instead of VARIANT
ARG BASE_IMAGE_VERSION_CODENAME=bullseye
FROM mcr.microsoft.com/vscode/devcontainers/base:${BASE_IMAGE_VERSION_CODENAME}

# Copy library scripts to execute
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/

ARG USERNAME=vscode
# JDK Version
ARG TARGET_JAVA_VERSION=11
# [Option] Install Maven
ARG INSTALL_MAVEN="false"
ARG MAVEN_VERSION=""
# [Option] Install Gradle
ARG INSTALL_GRADLE="false"
ARG GRADLE_VERSION=""
ENV LANG en_US.UTF-8
ENV SDKMAN_DIR="/usr/local/sdkman"
ENV PATH="${SDKMAN_DIR}/candidates/java/current/bin:${PATH}:${SDKMAN_DIR}/candidates/maven/current/bin:${SDKMAN_DIR}/candidates/gradle/current/bin"
# Install Java tools such as JDK, Maven and Gradle
RUN bash /tmp/library-scripts/java-debian.sh $TARGET_JAVA_VERSION "${SDKMAN_DIR}" "${USERNAME}" "true" \
	&& if [ "${INSTALL_MAVEN}" = "true" ]; then bash /tmp/library-scripts/maven-debian.sh "${MAVEN_VERSION:-latest}" "${SDKMAN_DIR}" ${USERNAME} "true"; fi \
	&& if [ "${INSTALL_GRADLE}" = "true" ]; then bash /tmp/library-scripts/gradle-debian.sh "${GRADLE_VERSION:-latest}" "${SDKMAN_DIR}" ${USERNAME} "true"; fi \
	&& apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Add symlinks to the installed JDK
RUN ls ${SDKMAN_DIR}/candidates/java | grep "^${TARGET_JAVA_VERSION}.*" > /tmp/library-scripts/jdkname \
	&& jdkName="$(cat /tmp/library-scripts/jdkname)" \
	&& ln -s ${SDKMAN_DIR}/candidates/java/${jdkName} /docker-java-home \
	&& if [ ! -d "/usr/lib/jvm" ]; then mkdir /usr/lib/jvm ; fi \
	&& ln -s ${SDKMAN_DIR}/candidates/java/${jdkName} /usr/lib/jvm/${jdkName}

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
ENV NVM_DIR=/usr/local/share/nvm
ENV NVM_SYMLINK_CURRENT=true \
	PATH="${NVM_DIR}/current/bin:${PATH}"
RUN bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}" \
	&& apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Remove library scripts for final image
RUN rm -rf /tmp/library-scripts

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
