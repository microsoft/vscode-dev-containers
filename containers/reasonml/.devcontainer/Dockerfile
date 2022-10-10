FROM mcr.microsoft.com/devcontainers/javascript-node:16-bullseye

RUN sudo -u node npm install -g bs-platform esy@latest

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends software-properties-common ocaml \
    && apt-add-repository ppa:fish-shell/release-3 \
    && apt-get -y install --no-install-recommends fish \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
