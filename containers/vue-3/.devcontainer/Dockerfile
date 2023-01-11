# [Choice] Base image version: 12, 14, 16 (refer to https://mcr.microsoft.com/v2/vscode/devcontainers/typescript-node/tags/list for full list)
ARG VARIANT
FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:${VARIANT}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends fzf silversearcher-ag \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ARG VUE_VERSION
ARG VUE_CLI_VERSION
ARG COMPILER_SFC_VERSION
ARG IONIC_VERSION
ARG VUEPRESS_VERSION
RUN su node -c "umask 0002 && npm install -g vue@${VUE_VERSION} @vue/compiler-sfc@${COMPILER_SFC_VERSION} @vue/cli@${VUE_CLI_VERSION} @ionic/cli@${IONIC_VERSION} vuepress@${VUEPRESS_VERSION}"

WORKDIR /app

EXPOSE 8080