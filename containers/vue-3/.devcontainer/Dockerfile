ARG BASE_IMAGE_VARIANT
FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:${BASE_IMAGE_VARIANT}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends fzf silversearcher-ag \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ARG YARN_VERSION
ARG VUE_VERSION
ARG VUE_CLI_VERSION
ARG COMPILER_SFC_VERSION
ARG IONIC_VERSION
ARG GRIDSOME_VERSION
RUN su node -c "umask 0002 && npm install -g yarn@${YARN_VERSION} vue@${VUE_VERSION} @vue/compiler-sfc@${COMPILER_SFC_VERSION} @vue/cli@${VUE_CLI_VERSION} @ionic/cli@${IONIC_VERSION} @gridsome/cli@${GRIDSOME_VERSION}"

WORKDIR /app

EXPOSE 8080