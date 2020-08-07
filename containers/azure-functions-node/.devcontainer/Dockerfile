# Find the Dockerfile for mcr.microsoft.com/azure-functions/node at the following URLs:
# Node 10: https://github.com/Azure/azure-functions-docker/blob/master/host/3.0/buster/amd64/node/node10/node10-core-tools.Dockerfile
# Node 12: https://github.com/Azure/azure-functions-docker/blob/master/host/3.0/buster/amd64/node/node12/node12-core-tools.Dockerfile
ARG VARIANT=12
FROM mcr.microsoft.com/azure-functions/node:3.0-node${VARIANT}-core-tools

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

