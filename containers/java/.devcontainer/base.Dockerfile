# This base.Dockerfile uses separate build arguments instead of VARIANT
ARG BASE_IMAGE_VERSION_CODENAME=bullseye
FROM debian:${BASE_IMAGE_VERSION_CODENAME}

# JDK Version
ARG TARGET_JAVA_VERSION=11
ENV LANG en_US.UTF-8

# Copy library scripts to execute
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"
# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
	&& apt-get clean -y && rm -rf /var/lib/apt/lists/*

# [Option] Install Maven
ARG INSTALL_MAVEN="false"
ARG MAVEN_VERSION=""
# [Option] Install Gradle
ARG INSTALL_GRADLE="false"
ARG GRADLE_VERSION=""
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
