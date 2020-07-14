ARG VARIANT=14
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:${VARIANT}

RUN sudo -u node npm install -g http-server @vue/cli @vue/cli-service-global
WORKDIR /app

EXPOSE 8080