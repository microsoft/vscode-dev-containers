#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
FROM debian:9

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Bazel version and hash
ENV BAZEL_VERSION=0.25.2 
ENV BAZEL_SHA256=5b9ab8a68c53421256909f79c47bde76a051910217531cbf35ee995448254fa7 

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1 \
    #
    # Verifty git, process tools, lsb-release (common in install instructions for CLIs) installed
    && apt-get -y install git procps lsb-release \
    #
    # Install Bazel
    && apt-get -y install curl pkg-config zip g++ zlib1g-dev unzip python \
    && curl -fSsL -o bazel-installer.sh https://github.com/bazelbuild/bazel/releases/download/0.25.2/bazel-0.25.2-installer-linux-x86_64.sh \
    && echo "${BAZEL_SHA256} *bazel-installer.sh" | sha256sum --check - \
    && chmod +x bazel-installer.sh \
    && ./bazel-installer.sh \
    && rm ./bazel-installer.sh \
    && echo '\n\
        export PATH="$PATH:$HOME/bin" \n\
        '\
        >> $HOME/.bashrc \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
