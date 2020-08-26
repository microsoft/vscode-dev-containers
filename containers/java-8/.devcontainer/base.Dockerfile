FROM mcr.microsoft.com/vscode/devcontainers/java:11

# Install JDK 8 and optionally Maven and Gradle - version of "" installs latest
ARG JDK8_VERSION=""
ARG INSTALL_MAVEN="false"
ARG MAVEN_VERSION=""
ARG INSTALL_GRADLE="false"
ARG GRADLE_VERSION=""
RUN su vscode -c "source /usr/local/sdkman/bin/sdkman-init.sh && if [ "${JDK8_VERSION}" = "" ]; then \
        sdk install java \$(sdk ls java | grep -m 1 -o ' 8.*.hs-adpt ' | awk '{print \$NF}'); \
        else sdk install java '${JDK8_VERSION}'; fi" \
    && if [ "${INSTALL_MAVEN}" = "true" ]; then su vscode -c "source /usr/local/sdkman/bin/sdkman-init.sh && sdk install maven \"${MAVEN_VERSION}\""; fi \
    && if [ "${INSTALL_GRADLE}" = "true" ]; then su vscode -c "source /usr/local/sdkman/bin/sdkman-init.sh && sdk install gradle \"${GRADLE_VERSION}\""; fi

# [Optional] Install a version of Node.js using nvm for front end dev
ARG INSTALL_NODE="true"
ARG NODE_VERSION="lts/*"
RUN if [ "${INSTALL_NODE}" = "true" ]; then su vscode -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>