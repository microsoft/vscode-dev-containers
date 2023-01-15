# [Choice] Node.js version (use -bullseye variants on local arm64/Apple Silicon): 18, 16, 14, 18-bullseye, 16-bullseye, 14-bullseye, 18-buster, 16-buster, 14-buster
ARG VARIANT=${templateOption:imageVariant}
FROM mcr.microsoft.com/devcontainers/javascript-node:0-${VARIANT}

RUN su node -c "umask 0002 && npm install -g http-server @vue/cli @vue/cli-service-global"
WORKDIR /app

EXPOSE 8080

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
