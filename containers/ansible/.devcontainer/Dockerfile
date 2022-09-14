# [Choice] Python version (use -bullseye variants on local arm64/Apple Silicon): 3, 3.10, 3.9, 3.8, 3.7, 3.6, 3-bullseye, 3.10-bullseye, 3.9-bullseye, 3.8-bullseye, 3.7-bullseye, 3.6-bullseye, 3-buster, 3.10-buster, 3.9-buster, 3.8-buster, 3.7-buster, 3.6-buster
ARG PYTHON_VARIANT=3-bullseye

FROM mcr.microsoft.com/vscode/devcontainers/python:${PYTHON_VARIANT}

# [Choice] Ansible variant: ansible, ansible-core, ansible-base
ARG ANSIBLE_VARIANT=ansible-core

# [Choice] Ansible Version: 2.9.*, 2.10.*, 2.11.*, 2.12.*
ARG ANSIBLE_VERSION=2.13.*

RUN pip3 --disable-pip-version-check --no-cache-dir install --upgrade pip wheel \
    && pip3 --disable-pip-version-check --no-cache-dir install ${ANSIBLE_VARIANT}==${ANSIBLE_VERSION}

# Create some default directories for ansible
RUN mkdir -p /ansible_collections \
    && mkdir -p ~/.ansible/collections

# [Optional] If your collection/role requirements rarely change, you can safe time with this section in the image.
# COPY requirements.yml /tmp/ansible-tmp/
# RUN ansible-galaxy collection install --no-cache -r /tmp/ansible-tmp/requirements.yml \
#     && rm -rf /tmp/ansible-tmp

# [Optional] If your pip requirements rarely change, uncomment this section to add them to the image.
# COPY requirements.txt /tmp/pip-tmp/
# RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
#    && rm -rf /tmp/pip-tmp

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>