#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG IMAGE_TO_TEST=debian:9
FROM ${IMAGE_TO_TEST}

ARG DISTRO="debian"
COPY common-${DISTRO}.sh /tmp/common-script.sh
RUN if [ "${DISTRO}" = "debian" ]; then apt-get update; fi \
    && chmod +x /tmp/common-script.sh \
    && /tmp/common-script.sh true vscode 1000 1000
