# [Choice] Python version (use -bullseye variants on local arm64/Apple Silicon): 3, 3.9, 3.8, 3.7, 3-bullseye, 3.9-bullseye, 3.8-bullseye, 3.7-bullseye, 3.6-bullseye, 3-buster, 3.9-buster, 3.8-buster, 3.7-buster
ARG VARIANT=3.8-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/python:${VARIANT}

# Create venv for device simulator
RUN python3 -m venv /opt/vscode/extensions/ms-python.devicesimulatorexpress/venv \
    && chown -R vscode:root /opt/vscode/extensions/ms-python.devicesimulatorexpress

# [Optional] If your pip requirements rarely change, uncomment this section to add them to the image.
# COPY requirements.txt /tmp/pip-tmp/
# RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
#     && rm -rf /tmp/pip-tmp

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
