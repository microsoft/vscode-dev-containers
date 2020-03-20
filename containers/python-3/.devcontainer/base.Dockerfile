#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG VARIANT=3
FROM python:${VARIANT}

# If you would prefer to have multiple Python versions in your container,
# replace the FROM statement above with the following:
#
# FROM ubuntu:bionic
# ARG PYTHON_PACKAGES="python3.5 python3.6 python3.7 python3.8 python3 python3-pip"
# RUN apt-get update && apt-get install --no-install-recommends -yq software-properties-common \
#    && add-apt-repository ppa:deadsnakes/ppa && apt-get update \
#    && apt-get install -yq --no-install-recommends ${PYTHON_PACKAGES} \
#    && pip3 install --upgrade pip setuptools wheel

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Uncomment the following COPY line and the corresponding lines in the `RUN` command if you wish to
# include your requirements in the image itself. Only do this if your requirements rarely change.
# COPY requirements.txt /tmp/pip-tmp/

# Set to false to skip installing zsh and Oh My ZSH!
ARG INSTALL_ZSH="true"

# Location and expected SHA for common setup script - SHA generated on release
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="dev-mode"

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Default set of utilities to install in a side virtual env
ARG DEFAULT_UTILS="\
    pylint \
    flake8 \
    autopep8 \
    black \
    pytest \
    yapf \
    mypy \
    pydocstyle \
    pycodestyle \
    prospector \
    pylama \
    bandit \
    virtualenv \
    pipx"
ARG UTILS_PATH=/usr/local/py-utils
ENV PATH=${PATH}:${UTILS_PATH}/bin

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog wget ca-certificates 2>&1 \
    #
    # Verify git, common tools / libs installed, add/modify non-root user, optionally install zsh
    && wget -q -O /tmp/common-setup.sh $COMMON_SCRIPT_SOURCE \
    && if [ "$COMMON_SCRIPT_SHA" != "dev-mode" ]; then echo "$COMMON_SCRIPT_SHA /tmp/common-setup.sh" | sha256sum -c - ; fi \
    && /bin/bash /tmp/common-setup.sh "$INSTALL_ZSH" "$USERNAME" "$USER_UID" "$USER_GID" \
    && rm /tmp/common-setup.sh \
    #
    # Setup default python tools in isloated location
    && mkdir -p ${UTILS_PATH}/bin \
    && chown -R ${USER_UID}:${USER_GID} ${UTILS_PATH} \
    && PYTHONUSERBASE=/tmp/pipx-tmp \
        pip3 --disable-pip-version-check --no-cache-dir install --no-warn-script-location --user pipx \
    && echo "${DEFAULT_UTILS}" | \
        PYTHONUSERBASE=/tmp/pipx-tmp \
        PIPX_HOME=${UTILS_PATH} \
        PIPX_BIN_DIR=${UTILS_PATH}/bin \
        xargs -n 1 /tmp/pipx-tmp/bin/pipx install --pip-args=--no-cache-dir \
    && rm -rf /tmp/pipx-tmp \
    #
    # Update Python environment based on requirements.txt
    # && pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
    # && rm -rf /tmp/pip-tmp \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog


