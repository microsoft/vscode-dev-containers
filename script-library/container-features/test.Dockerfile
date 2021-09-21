ARG BASE_IMAGE=mcr.microsoft.com/vscode/devcontainers/base:buster
FROM $BASE_IMAGE

USER root

COPY . /tmp/build-features/

RUN cd /tmp/build-features \
&& chmod +x ./install.sh \
&& ./install.sh

#{containerEnv}

ARG IMAGE_USER=root
USER $IMAGE_USER