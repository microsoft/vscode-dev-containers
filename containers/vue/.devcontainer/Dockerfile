FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:14

RUN npm install -g http-server @vue/cli @vue/cli-service-global
WORKDIR /app
COPY . .

EXPOSE 8080
CMD [ "/usr/local/bin/npm run serve" ]