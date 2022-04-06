# [Choice] Java version (use -bullseye variants on local arm64/Apple Silicon): 11, 17, 11-bullseye, 17-bullseye, 11-buster, 17-buster
ARG VARIANT="17"
FROM mcr.microsoft.com/vscode/devcontainers/java:0-${VARIANT}

# [Optional] Scala version (leave blank for latest)
ARG SCALA_VERSION=""

# [Option] Install Mill
ARG INSTALL_MILL="false"

# [Option] Install SBT
ARG INSTALL_SBT="false"

# [Option] Install Clang (required for Scala Native)
ARG INSTALL_CLANG="false"

RUN curl -fLJ -o /usr/local/bin/scala-cli https://github.com/Virtuslab/scala-cli/releases/latest/download/scala-cli && \
    chmod +x /usr/local/bin/scala-cli && \
    su vscode -c "scala-cli compile . --scala=${SCALA_VERSION}"

RUN if [ "${INSTALL_MILL}" = "true" ]; then \
    curl -o /usr/local/bin/mill https://raw.githubusercontent.com/lefou/millw/main/millw && \
    chmod +x /usr/local/bin/mill && \
    (cd /tmp; su vscode -c "mill resolve _"); fi

RUN if [ "${INSTALL_SBT}" = "true" ]; then \
    echo "deb [signed-by=/usr/share/keyrings/sbt-archive-keyring.gpg] https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list && \
    echo "deb [signed-by=/usr/share/keyrings/sbt-archive-keyring.gpg] https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --dearmor | sudo tee /usr/share/keyrings/sbt-archive-keyring.gpg > /dev/null && \
    sudo apt-get update && \
    sudo apt-get install sbt && \
    (cd /tmp; su vscode -c "sbt --version") && \
    rm -rf /var/lib/apt/lists/*; fi

RUN if [ "${INSTALL_CLANG}" = "true" ]; then apt-get update && apt-get -y install clang && su vscode -c "scala-cli compile . --native" && rm -rf /var/lib/apt/lists/*; fi

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1