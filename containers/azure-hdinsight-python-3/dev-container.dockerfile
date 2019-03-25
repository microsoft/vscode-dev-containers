#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

# HDInsight extension needs mono
FROM mono:5

# Install git tools
RUN apt-get update \
    && apt-get install -y git

# Install python 3
RUN apt-get install -y python3 python3-pip

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*