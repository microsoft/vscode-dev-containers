# [Choice] Java version (use -bullseye variants on local arm64/Apple Silicon): 11, 16, 11-bullseye, 16-bullseye, 11-buster, 16-buster
ARG VARIANT=11-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/java:${VARIANT}

# [Optional] Install Clojure CLI tools
ARG INSTALL_CLOJURE_CLI="true"

# [Option] Install Leiningen
ARG INSTALL_LEININGEN="true"

RUN if [ "${INSTALL_CLOJURE_CLI}" = "true" ]; then \
    apt-get update \
    && apt-get -y install rlwrap \
    && curl -O "https://download.clojure.org/install/linux-install-1.10.3.981.sh" \
    && chmod +x /linux-install-1.10.3.981.sh \
    && /linux-install-1.10.3.981.sh \
    && rm /linux-install-1.10.3.981.sh \
    && clj --version; fi

RUN if [ "${INSTALL_LEININGEN}" = "true" ]; then \
    curl -O "https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein" \
    && chmod +x lein \
    && mv lein /usr/local/sbin \
    && /usr/local/sbin/lein --version; fi

# Clean up package lists
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1
