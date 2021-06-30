#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG ORIGINAL_IMAGE=mcr.microsoft.com/vscode/devcontainers/universal@sha256:f5b9396bc432b774c946e9d626d8970a4d0ddcb0302a436d6aa99b76280cd7de
FROM ${ORIGINAL_IMAGE}

ARG PACKAGE_LIST="\
moby-cli \
apt \
curl \
krb5-admin-server \
krb5-k5tls \
krb5-kdc \
krb5-kdc-ldap \
krb5-kpropd \
krb5-locales \
krb5-multidev \
krb5-otp \
krb5-pkinit \
krb5-user \
libgssapi-krb5-2 \
libgssrpc4 \
libk5crypto3 \ 
libkadm5clnt-mit11 \
libkadm5srv-mit11 \
libkdb5-9 \
libkrad0 \
libkrb5-3 \
libkrb5support0 \
libssl1.1 \
libssl1.0.0 \
libssl1.0.2 \
openldap \
zsh \ 
libmaxminddb \
libexif \
freetype \
mariadb-10.3"

RUN sudo apt-get update && sudo bash -c "\
        export DEBIAN_FRONTEND=noninteractive \
        && echo \"${PACKAGE_LIST}\" | tr ' ' '\n' | while  read PKG; do \
            echo \"Checking \$PKG...\" \
            && if [ \"\$PKG\" != '' ] && dpkg -s \$PKG >/dev/null 2>&1; then sudo apt-get upgrade -yq \$PKG; fi; \
        done \
        && apt-get autoremove -y \
        && apt-get clean -y \
        && rm -rf /var/lib/apt/lists/*"
