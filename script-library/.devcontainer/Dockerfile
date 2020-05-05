#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG IMAGE_TO_TEST=debian:9
FROM ${IMAGE_TO_TEST}

ARG DISTRO="debian"
ARG USERNAME="vscode"

COPY *.sh /tmp/

RUN if [ "${DISTRO}" = "debian" ]; then apt-get update; fi

RUN chmod +x /tmp/*.sh

RUN /tmp/common-${DISTRO}.sh true ${USERNAME} 1000 1000

RUN if [ "${DISTRO}" = "debian" ]; then \
        /tmp/docker-${DISTRO}.sh true /var/run/docker-host.sock /var/run/docker.sock ${USERNAME}; \
    fi

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access to 
# the Docker socket if "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
