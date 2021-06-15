# [Choice] .NET version: 5.0, 3.1, 2.1
ARG VARIANT="3.1"
FROM mcr.microsoft.com/dotnet/sdk:${VARIANT}-focal

# [Option] Install zsh
ARG INSTALL_ZSH="true"

# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"

# [Option] Install Azure CLI
ARG INSTALL_AZURE_CLI="false"

# [Option] Install Node.js
ARG INSTALL_NODE="true"
ARG NODE_VERSION="none"
ENV NVM_DIR=/usr/local/share/nvm
ENV NVM_SYMLINK_CURRENT=true \
    PATH=${NVM_DIR}/current/bin:${PATH}

# Runs all scripts in the library-scripts folder in alphabetical order using argumetns set in this file. 
# You can add your own install steps to "library-scripts/user-install-steps.sh" or another file in this folder.
COPY library-scripts /tmp/library-scripts
RUN bash /tmp/library-scripts/install base \
    && rm -rf /tmp/library-scripts
