#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# To fully customize the contents of this image, use the following Dockerfile instead:
# https://github.com/microsoft/vscode-dev-containers/tree/v0.128.0/containers/javascript-node-12/.devcontainer/Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:0-12

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends tar jq wget

RUN wget -qO- https://api.github.com/repos/exercism/cli/releases/latest 2>/dev/null | \
    jq -r '.assets[] | select(.browser_download_url | contains("linux-x86_64")) | .browser_download_url' | \
    xargs -n1 wget -O - -q | tar -xvzf - -C /usr/bin && \
    npm install -g pnpm