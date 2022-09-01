# Find the Dockerfile at the following URL:
# Node 14: https://github.com/Azure/azure-functions-docker/blob/dev/host/4/bullseye/amd64/node/node14/node14-core-tools.Dockerfile
# Node 16: https://github.com/Azure/azure-functions-docker/blob/dev/host/4/bullseye/amd64/node/node16/node16-core-tools.Dockerfile
ARG VARIANT=14
FROM mcr.microsoft.com/azure-functions/node:4-node${VARIANT}-core-tools

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment if you want to run your Function locally with 
# local.settings.json using `"AzureWebJobsStorage": "UseDevelopmentStorage=true"`
# RUN sudo -u node npm install -g azurite

# [Optional] Uncomment if you want to install more global node packages
# RUN sudo -u node npm install -g <your-package-list-here>
