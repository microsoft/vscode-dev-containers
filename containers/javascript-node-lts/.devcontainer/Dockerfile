#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM node:lts

# Configure apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

# Verify git and needed tools are installed
RUN apt-get install -y git curl tar procps

# Update Yarn to latest
# See https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md#upgradingdowngrading-yarn
RUN curl -sfSLO --compressed "https://yarnpkg.com/latest.tar.gz" \
    && rm -rf /opt/yarn-* \
    && tar -xzf latest.tar.gz -C /opt/ \
    && ln -snf /opt/yarn-v*/bin/yarn /usr/local/bin/yarn \
    && ln -snf /opt/yarn-v*/bin/yarnpkg /usr/local/bin/yarnpkg \
    && rm latest.tar.gz
    
# Install eslint
RUN npm install -g eslint

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog
