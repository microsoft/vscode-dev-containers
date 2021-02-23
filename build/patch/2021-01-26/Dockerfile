#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/universal@sha256:450ad0ff434cb48c812d5ef0dfb50b35bdbbda78d64c785d5bc01cf331916948
FROM ${ORIGINAL_IMAGE}

ARG PACKAGE_LIST="\
libcurl3-gnutls \
libcairo-gobject2 \
libcairo2 \
openjdk-8-jdk \
openjdk-8-jdk-headless \
openjdk-8-jre \
openjdk-8-jre-headless \
libflac8 \
libssl1.1 \
libp11-kit0 \
libp11-kit-dev \
apt-transport-https \
libapt-inst2.0 \
libapt-pkg5.0 \
firefox-esr \
libproxy1v5 \
"

ARG PATCH_SCRIPT="\
    export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && echo \"${PACKAGE_LIST}\" | tr ' ' '\n' | while read PKG; do \
        echo \"Checking \$PKG...\" \
        && if [ \"\$PKG\" != '' ] && dpkg -s \$PKG >/dev/null 2>&1; then apt-get install -yq --only-upgrade \$PKG; fi; \
    done \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*"

RUN echo "${PATCH_SCRIPT}" \
    && if [ "$(id -u)" -ne 0 ]; then \
        sudo bash -c "${PATCH_SCRIPT}"; \
    else \
        bash -c "${PATCH_SCRIPT}"; \
    fi
