#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/universal@sha256:924b041a59f036045c0207275f56156cae3ccc1e74b5629d76c60342eb97ec11
FROM ${ORIGINAL_IMAGE}

ARG PACKAGE_LIST="\
moby-cli \
moby-engine \
"

ARG PATCH_SCRIPT="\
    export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && echo \"${PACKAGE_LIST}\" | tr ' ' '\n' | while read PKG; do \
        echo \"Checking \$PKG...\" \
        && if [ \"\$PKG\" != '' ] && dpkg -s \$PKG >/dev/null 2>&1; then apt-get install -yq --no-install-recommends --only-upgrade \$PKG; fi; \
    done \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*"

RUN echo "${PATCH_SCRIPT}" \
    && if [ "$(id -u)" -ne 0 ]; then \
        sudo bash -c "${PATCH_SCRIPT}"; \
    else \
        bash -c "${PATCH_SCRIPT}"; \
    fi
