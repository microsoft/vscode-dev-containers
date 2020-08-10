#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Test defaults
ARG IMAGE_TO_TEST=debian:10
FROM ${IMAGE_TO_TEST}

COPY *.sh /tmp/
COPY test/*.sh /tmp
RUN chmod +x /tmp/*.sh

ARG DISTRO="debian"
ARG USE_DEFAULTS="true"
ARG USERNAME="vscode"
RUN /tmp/run-scripts.sh /tmp ${DISTRO} ${USE_DEFAULTS} ${USERNAME} false false 10

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
