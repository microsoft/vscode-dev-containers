#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/javascript-node@sha256:58ecafbc0455c024b3bcdde60036f262edc3d139b8308c8f5e6e17c55252253a
FROM ${ORIGINAL_IMAGE}

ARG PACKAGE_LIST="\
sudo \
linux-libc-dev \
libp11-kit0 \
"

# Script to iterate through the above list and update packages
ARG PATCH_SCRIPT="\
    export DEBIAN_FRONTEND=noninteractive \
    && if type yarn > /dev/null 2>&1; then curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT); fi \
    && apt-get update \
    && echo \"${PACKAGE_LIST}\" | tr ' ' '\n' | while read PKG; do \
        echo \"Checking \$PKG...\" \
        && if [ \"\$PKG\" != '' ] && dpkg -s \$PKG >/dev/null 2>&1; then apt-get install -yq --only-upgrade --no-install-recommends \$PKG; fi; \
    done \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    "

RUN echo "${PATCH_SCRIPT}" \
    && if [ "$(id -u)" -ne 0 ]; then \
        sudo bash -c "${PATCH_SCRIPT}"; \
    else \
        bash -c "${PATCH_SCRIPT}"; \
    fi
