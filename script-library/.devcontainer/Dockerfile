#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

ARG IMAGE_TO_TEST=debian:10
FROM ${IMAGE_TO_TEST}

ARG DISTRO="debian"
ARG USERNAME="vscode"
ARG INSTALL_DOCKER="true"
ARG UPGRADE_PACKAGES="true"
ARG DEBIAN_FRONTEND=noninteractive

COPY *.sh /tmp/
RUN chmod +x /tmp/*.sh \
    && if [ "${DISTRO}" = "debian" ]; then \
      apt-get update; \
    fi

# Run common script
RUN /tmp/common-${DISTRO}.sh true ${USERNAME} 1000 1000 ${UPGRADE_PACKAGES}

# Optionally run docker script
RUN if [ "${DISTRO}" = "debian" ] && [ "${INSTALL_DOCKER}" = "true" ]; then \
        /tmp/docker-${DISTRO}.sh true /var/run/docker-host.sock /var/run/docker.sock ${USERNAME}; \
    else \
        echo "#!/bin/bash\n\$@" > /usr/local/share/docker-init.sh \
        && chmod +x /usr/local/share/docker-init.sh \
        && chown ${USERNAME} /usr/local/share/docker-init.sh; \
    fi

RUN if [ "${DISTRO}" = "debian" ]; then \
        apt-get autoremove -y \
        && apt-get clean -y \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access to 
# the Docker socket if "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
