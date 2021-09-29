# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.194.0/containers/dotnet/.devcontainer/base.Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/dotnet:0-3.1

# Install Docker CE
COPY library-scripts/*.sh /tmp/library-scripts/
RUN \
    apt-get update -y \
    # Use Docker script from script library to set things up - enable non-root docker, user vscode, using moby
    && /bin/bash /tmp/library-scripts/docker-in-docker-debian.sh "true" "vscode" "true" \
    # install iotedgehubdev
    && apt-get install -y python3-pip && pip3 install iotedgehubdev \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
