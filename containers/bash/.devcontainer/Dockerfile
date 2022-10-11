# [Choice] Debian / Ubuntu version (use Debian 11/9, Ubuntu 18.04/21.04 on local arm64/Apple Silicon): debian-11, debian-10, debian-9, ubuntu-21.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT=${templateOption:imageVariant}
FROM mcr.microsoft.com/devcontainers/base:${VARIANT}
WORKDIR /src

# [Optional] Uncomment this section to install additional OS packages you may want.
#
# RUN apk add --no-cache <your-package-list-here>
