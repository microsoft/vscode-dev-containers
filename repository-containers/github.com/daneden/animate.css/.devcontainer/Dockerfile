#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM node:10

# Install git, process tools
RUN apt-get update && apt-get -y install git procps

# Install animate.css via npm
RUN npm install animate.css --save

# Uncomment to install animate.css via yarn
# RUN yarn add animate.css

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
