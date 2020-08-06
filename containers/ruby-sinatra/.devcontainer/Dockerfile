# See here for image contents: https://github.com/microsoft/vscode-dev-containers/blob/master/containers/ruby/.devcontainer/base.Dockerfile
ARG VARIANT=2
FROM mcr.microsoft.com/vscode/devcontainers/ruby:${VARIANT}

# Install Sinatra
RUN gem install sinatra sinatra-reloader thin data_mapper dm-sqlite-adapter 

# Install a version of Node.js using nvm
ARG NODE_VERSION="lts/*"
RUN sudo -u vscode bash -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION}" 2>&1

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install additional gems.
# RUN gem install <your-gem-names-here>
