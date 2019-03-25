#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

# **************************************************************************
# * Note: A dev-container.dockerfile is optional when using Docker Compose *
# *       but has been included here for completeness.                     *
# **************************************************************************

# Debian and Ubuntu based images are supported. Alpine images are not yet supported.
FROM ubuntu:1804

# Install common tools developers typically will need like git
RUN apt-get update \
	&& apt-get install -y git

# *****************************************************
# * Add steps for installing needed dependencies here *
# *****************************************************

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

