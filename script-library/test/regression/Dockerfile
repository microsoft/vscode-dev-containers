#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Test defaults
ARG IMAGE_TO_TEST=debian:10
FROM ${IMAGE_TO_TEST}

USER root

RUN . /etc/os-release \
    && if [ "${ID}" = "alpine" ] || [ "${ID_LIKE}" = "alpine" ]; then apk add bash; fi

ARG USERNAME="vscode"
ARG RUN_COMMON_SCRIPT="true"
ARG UPGRADE_PACKAGES="false"
ARG RUN_ONE="false"
RUN --mount=target=/script-library,source=.,type=bind,rw \
    bash /script-library/test/regression/run-scripts.sh /script-library true ${USERNAME} ${RUN_COMMON_SCRIPT} ${UPGRADE_PACKAGES} ${RUN_ONE}

ENV DBUS_SESSION_BUS_ADDRESS="autolaunch:" DISPLAY=":1" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
ENTRYPOINT [ "/usr/local/share/docker-init.sh", "/usr/local/share/ssh-init.sh", "/usr/local/share/desktop-init.sh" ]
CMD [ "sleep", "infinity" ]
