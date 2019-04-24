#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM maven:3-jdk-12

# Install git, process tools
RUN yum update -y && yum install -y git procps

# Clean yum cache
RUN yum clean all
