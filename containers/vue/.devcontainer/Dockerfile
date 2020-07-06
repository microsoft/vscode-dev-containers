FROM node:lts-alpine

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apk add --no-cache sudo git openssh-client \
	&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
	&& chmod 0440 /etc/sudoers.d/$USERNAME

RUN npm install -g http-server @vue/cli @vue/cli-service-global
WORKDIR /app
COPY . .

EXPOSE 8080
CMD [ "/usr/local/bin/npm run serve" ]