# [Choice] Ruby version (use -bullseye variants on local arm64/Apple Silicon): 3, 3.1, 3.0, 2, 2.7, 2.6, 3-bullseye, 3.1-bullseye, 3.0-bullseye, 2-bullseye, 2.7-bullseye, 2.6-bullseye, 3-buster, 3.1-buster, 3.0-buster, 2-buster, 2.7-buster, 2.6-buster
ARG VARIANT=${templateOption:imageVariant}
FROM mcr.microsoft.com/devcontainers/ruby:${VARIANT}

# Install Sinatra
RUN gem install sinatra sinatra-reloader thin data_mapper dm-sqlite-adapter 

# [Choice] Node.js version: lts/*, 16, 14, 12, 10
ARG NODE_VERSION="${templateOption:nodeVersion}"
RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install additional gems.
# RUN gem install <your-gem-names-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1