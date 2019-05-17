#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
FROM debian:9

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

# Install git, process tools, lsb-release (common in install instructions for CLIs)
RUN apt-get -y install git procps lsb-release

# Install Bazel
ENV BAZEL_VERSION=0.25.2
ENV BAZEL_SHA256=7ca3bbec5730afc3732514cbebb1e8f451df455d85d6bed5eb5614c2bfe36f13
RUN apt-get -y install curl pkg-config zip g++ zlib1g-dev unzip python
RUN curl -fSsL -o bazel-installer.sh https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh \
    && chmod +x bazel-installer.sh \
    && ./bazel-installer.sh \
    && rm ./bazel-installer.sh

RUN echo '\n\
    export PATH="$PATH:$HOME/bin" \n\
    '\
    >> $HOME/.bashrc

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog
