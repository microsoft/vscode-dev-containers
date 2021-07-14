ARG BASE_IMAGE=mcr.microsoft.com/vscode/devcontainers/base:buster
FROM $BASE_IMAGE

USER root

#{containerEnv}

COPY feature-scripts.env features.env install.sh library-scripts/*.sh /tmp/library-scripts/
RUN /tmp/library-scripts/install.sh \
    && rm -rf /tmp/library-scripts

ARG IMAGE_USER=root
USER $IMAGE_USER

