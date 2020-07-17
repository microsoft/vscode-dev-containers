# Update the VARIANT arg in devcontainer.json to pick a Python version: 3 (latest), 3.6, 3.7, 3.8
ARG VARIANT=3.8
FROM mcr.microsoft.com/vscode/devcontainers/python:${VARIANT}

# Install Pipenv
RUN /usr/local/py-utils/bin/pipx install \
        --system-site-packages \
        --pip-args=--no-cache-dir \
        --pip-args=--force-reinstall \
        pipenv \
    && chown -R ${USER_UID}:${USER_GID} ${PIPX_HOME}

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
