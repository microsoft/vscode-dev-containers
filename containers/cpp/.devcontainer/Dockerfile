#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM ubuntu:bionic

# Install git
RUN apt-get update && apt-get -y install git

# Install C++ tools
RUN apt-get -y install build-essential cmake cppcheck valgrind

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
