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
ARG RUN_COMMON_SCRIPT="true"
ARG UPGRADE_PACKAGES="false"
RUN /tmp/run-scripts.sh /tmp ${DISTRO} ${USE_DEFAULTS} ${USERNAME} ${RUN_COMMON_SCRIPT} ${UPGRADE_PACKAGES}

ENV DBUS_SESSION_BUS_ADDRESS="autolaunch:" DISPLAY=":1" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
ENTRYPOINT [ "/usr/local/share/docker-init.sh", "/usr/local/share/ssh-init.sh", "/usr/local/share/desktop-init.sh" ]
CMD [ "sleep", "infinity" ]
