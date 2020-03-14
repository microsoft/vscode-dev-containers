#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM tensorflow/tensorflow:2.1.0-custom-op-gpu-ubuntu16

# Install git
RUN apt-get update && apt-get -y install git

# Install dev tools

# Install tensorflow
RUN pip install tensorflow~=2.1.0 typeguard>=2.7

COPY tools/install_deps/finish_bazel_install.sh ./
RUN bash finish_bazel_install.sh

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
