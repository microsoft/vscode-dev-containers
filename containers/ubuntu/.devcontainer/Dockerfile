# [Choice] Ubuntu version: bionic, focal
ARG VARIANT=focal
FROM mcr.microsoft.com/vscode/devcontainers/base:${VARIANT}

# Runs all scripts in the library-scripts folder in alphabetical order. You can add your own
# install steps to "library-scripts/user-install-steps.sh" or another file in this folder.
COPY library-scripts/install library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/
RUN bash /tmp/library-scripts/install \
    && rm -rf /tmp/library-scripts
