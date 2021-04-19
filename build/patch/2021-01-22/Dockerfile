#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/universal:0.16.0
#ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/universal:1.1.0
#ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/universal@sha256:8fc6883411913acca538ef054c4f6508c4e28745f39ae3d8af6ce327787bb49c
FROM ${ORIGINAL_IMAGE}

ARG PACKAGE_LIST="\
apt \
curl \
openssl \
p11-kit \
krb5-3 \
openldap \
libgssapi-krb5-2 \
tzdata \
"

ARG PATCH_SCRIPT="\
    export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && echo \"${PACKAGE_LIST}\" | tr ' ' '\n' | while read PKG; do \
        echo \"Checking \$PKG...\" \
        && if [ \"\$PKG\" != '' ] && dpkg -s \$PKG >/dev/null 2>&1; then apt-get install -yq --only-upgrade \$PKG; fi; \
    done \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    && echo 'Checking for go...' \
    && if type go > /dev/null 2>&1; then \
        echo 'Go found.' \
        && GOVERSION=\"\$(go version | grep -oE '[0-9]+\.[0-9]+(\.| )[0-9]*')\" \
        && echo \"Go version: \$GOVERSION\" \
        && GOMINOR=\$(echo \"\$GOVERSION\" | grep -oE '\.[0-9]+(\.| )' | tr -d '.' | tr -d ' ') \
        && GOFIX=\$(echo \"\$GOVERSION\" | grep -oE '\.[0-9]+$' | tr -d '.' | tr -d ' ') \
        && if [ \"\$GOFIX\" = '' ]; then GOFIX=0; fi \
        && TARGETGO='none' \
        && if [ \$GOMINOR = '14' ] && [ \$GOFIX -lt 14 ]; then TARGETGO=1.14.14; fi \
        && if [ \$GOMINOR = '15' ] && [ \$GOFIX -lt 7 ]; then TARGETGO=1.15.7; fi \
        && if [ \$TARGETGO != 'none' ]; then \
            echo \"Target Go version: \$TARGETGO\" \
            && curl -L https://golang.org/dl/go\${TARGETGO}.linux-amd64.tar.gz -o /tmp/golang.tar.gz \
            && tar -C /usr/local -xzf /tmp/golang.tar.gz \
            && rm -f /tmp/golang.tar.gz; \
        else \
            echo 'Go already up to date.'; \
        fi; \
    else \
        echo 'Go not installed. Skipping.'; \
    fi"

RUN echo "${PATCH_SCRIPT}" \
    && if [ "$(id -u)" -ne 0 ]; then \
        sudo bash -c "${PATCH_SCRIPT}"; \
    else \
        bash -c "${PATCH_SCRIPT}"; \
    fi
