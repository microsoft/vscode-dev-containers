ARG BASE_IMAGE=mcr.microsoft.com/vscode/devcontainers/base:buster
FROM $BASE_IMAGE

USER root

COPY *.env *.sh /tmp/library-scripts/
RUN /tmp/library-scripts/install.sh \
    && rm -rf /tmp/library-scripts

#{containerEnv}

ARG IMAGE_USER=root
USER $IMAGE_USER
