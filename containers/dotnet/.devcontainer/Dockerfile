# [Choice] .NET version: 5.0, 3.1, 2.1
ARG VARIANT=3.1
FROM mcr.microsoft.com/vscode/devcontainers/dotnet:0-${VARIANT}

# [Option] Install Node.js
ARG INSTALL_NODE="true"
ARG NODE_VERSION="lts/*"

# Runs all scripts in the library-scripts folder in alphabetical order using argumetns set in this file. 
# You can add your own install steps to "library-scripts/user-install-steps.sh" or another file in this folder.
COPY library-scripts /tmp/library-scripts
RUN bash /tmp/library-scripts/install \
    && rm -rf /tmp/library-scripts

