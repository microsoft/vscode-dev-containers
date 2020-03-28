#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Azure ML does not support Debian, so need to use an Ubuntu image
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-18.04

ARG ANACONDA_VERSION=2020.02

# The javascript-node image includes a non-root node user with sudo access. Use 
# the "remoteUser" property in devcontainer.json to use it. On Linux, the container 
# user's GID/UIDs will be updated to match your local UID/GID when using the image
# or dockerFile property. Update USER_UID/USER_GID below if you are using the
# dockerComposeFile property or want the image itself to start with different ID
# values. See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

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
    bandit \
    virtualenv \
    pipx"
ENV PIPX_HOME=/usr/local/py-utils
ENV PIPX_BIN_DIR=${PIPX_HOME}/bin
ENV PATH=/opt/conda/bin:${PATH}:${PIPX_BIN_DIR}
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    #
    # Alter vscode user as needed
    && if [ "$USER_GID" != "1000" ] || [ "$USER_UID" != "1000" ]; then \
        groupmod --gid $USER_GID $USERNAME \
        && usermod --uid $USER_UID --gid $USER_GID $USERNAME \
        && chown -R $USER_UID:$USER_GID /home/$USERNAME; \
    fi \
    #
    # Set up Anaconda - adapted for Ubuntu from https://github.com/ContinuumIO/docker-images/blob/master/anaconda3/debian/Dockerfile
    && apt-get install -y bzip2 libglib2.0-0 libxext6 libsm6 libxrender1 gcc g++ \
    && mkdir -p /opt/conda \
    && chown ${USERNAME} /opt/conda \
    && echo "Downloading Anaconda..." \
    && wget -q https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh -O /opt/conda/anaconda-install.sh \
    && /bin/bash /opt/conda/anaconda-install.sh -u -b -p /opt/conda 2>&1  \
    && rm /opt/conda/anaconda-install.sh \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" | tee -a /root/.bashrc >> /home/${USERNAME}/.bashrc \
    && echo ". /opt/conda/etc/profile.d/conda.sh" | tee -a /root/.zshrc >> /home/${USERNAME}/.zshrc \
    && echo "conda activate base" | tee -a /root/.bashrc >> /home/${USERNAME}/.bashrc \
    && echo "conda activate base" | tee -a /root/.zshrc >> /home/${USERNAME}/.zshrc \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
    && /opt/conda/bin/conda clean -afy \
    #
    # Install Docker CLI
    && apt-get install -y gnupg-agent software-properties-common \
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    #
    # Install and Azure ML SDK
    && /opt/conda/bin/pip install azureml-sdk[notebooks,automl] 2>&1 \
    #
    # Setup default python tools in venv'd OS version of python to avoid conflicts
    && mkdir -p ${PIPX_BIN_DIR} \
    && chown -R ${USER_UID}:${USER_GID} ${PIPX_HOME} \
    && PYTHONUSERBASE=/tmp/pip-tmp pip install --disable-pip-version-check --no-warn-script-location --no-cache-dir --user pipx \
    && echo "${DEFAULT_UTILS}" | PYTHONUSERBASE=/tmp/pip-tmp xargs -n 1 /tmp/pip-tmp/bin/pipx install --pip-args=--no-cache-dir \
    && rm -rf /tmp/pip-tmp \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
