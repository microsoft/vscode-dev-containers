# [Choice] Node.js version: 18, 16, 14
ARG VARIANT=${templateOption:imageVariant}
FROM mcr.microsoft.com/devcontainers/javascript-node:${VARIANT}

# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="${templateOption:enableNonRootDocker}"
# [Option] Use the OSS Moby Engine instead of the licensed Docker Engine
ARG USE_MOBY="${templateOption:moby}"

ARG USERNAME=node

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
COPY library-scripts/docker-debian.sh /tmp/library-scripts/
RUN apt-get update \
    # Use Docker script from script library to set things up
    && /bin/bash /tmp/library-scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}" \
    # Install Dapr
    && wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

# Add daprd to the path for the VS Code Dapr extension.
ENV PATH "$PATH:/home/${USERNAME}/.dapr/bin"

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access 
# to the Docker socket. The script will also execute CMD as needed.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
