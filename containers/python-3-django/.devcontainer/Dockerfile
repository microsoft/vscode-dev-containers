#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM python:3-slim

ENV PYTHONUNBUFFERED 1

RUN pip install pylint

RUN mkdir /app
WORKDIR /app

COPY .devcontainer/requirements.txt /app/
RUN pip install -r requirements.txt

# Install git
RUN apt-get update && apt-get -y install git

# Install any missing dependencies for enhanced language service
RUN apt-get install -y libicu57

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
