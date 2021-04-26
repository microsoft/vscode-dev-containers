# Update the VARIANT arg in devcontainer.json to pick a Python version: 3.7, 3.8 or higher
ARG VARIANT=3.8
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
