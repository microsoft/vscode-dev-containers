# Update the VARIANT arg in devcontainer.json to pick a Ruby version: 2, 2.7, 2.6, 2.5
ARG VARIANT=14
FROM mcr.microsoft.com/vscode/devcontainers/ruby:${VARIANT}

# [Optional] Install a version of Node.js using nvm
ARG INSTALL_NODE="true"
ARG NODE_VERSION="lts/*"
RUN if [ "${INSTALL_NODE}" = "true" ]; then \
        sudo -u vscode bash -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION}"; \
    fi

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install additional gems.
# RUN gem install <your-gem-names-here>

