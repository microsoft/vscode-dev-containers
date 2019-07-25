#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM debian:9

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configuring Elm version
ARG ELM_VERSION=0.19.0


# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1 \ 
    #
    # Verify git and needed tools are installed
    && apt-get install -y git procps \
    && apt-get install -y wget \
    #
    # Install elm globally
    && wget -O - https://github.com/elm/compiler/releases/download/${ELM_VERSION}/binary-for-linux-64-bit.gz | gunzip -c > /usr/local/bin/elm && chmod +x /usr/local/bin/elm \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
