# [Choice] Debian OS version (use bullseye on local arm64/Apple Silicon): buster, bullseye
ARG VARIANT="bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/base:${VARIANT}

# Install JDK 8 and optionally Maven and Gradle - version of "" installs latest
ARG JDK8_VERSION=""
ARG INSTALL_MAVEN="false"
ARG MAVEN_VERSION=""
ARG INSTALL_GRADLE="false"
ARG GRADLE_VERSION=""
# Copy library scripts to execute
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/

ENV SDKMAN_DIR="/usr/local/sdkman"
ENV PATH="${SDKMAN_DIR}/candidates/java/current/bin:${PATH}:${SDKMAN_DIR}/candidates/maven/current/bin:${SDKMAN_DIR}/candidates/gradle/current/bin"
RUN if [ "${JDK8_VERSION}" = "" ]; then bash /tmp/library-scripts/java-debian.sh "8" "${SDKMAN_DIR}" "${USERNAME}" "true" \
        else bash /tmp/library-scripts/java-debian.sh "${JDK8_VERSION}" "${SDKMAN_DIR}" "${USERNAME}" "true"; fi \
    && if [ "${INSTALL_MAVEN}" = "true" ]; then bash /tmp/library-scripts/maven-debian.sh "${MAVEN_VERSION:-latest}" "${SDKMAN_DIR}" ${USERNAME} "true"; fi \
    && if [ "${INSTALL_GRADLE}" = "true" ]; then bash /tmp/library-scripts/gradle-debian.sh "${GRADLE_VERSION:-latest}" "${SDKMAN_DIR}" ${USERNAME} "true"; fi \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

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
