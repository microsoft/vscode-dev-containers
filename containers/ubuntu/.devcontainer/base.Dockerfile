# Update the VARIANT arg in devcontainer.json to pick an Ubuntu version: focal, bionic
ARG VARIANT="focal"
FROM buildpack-deps:${VARIANT}-curl

# Options - Can also be set in library-scripts/library-scripts.env
ARG COMMON_INSTALL_ZSH="true"
ARG COMMON_UPGRADE_PACKAGES="true"

# Runs all scripts in the library-scripts folder in alphabetical order using argumetns set in this file. 
# You can add your own install steps to "library-scripts/user-install-steps.sh" or another file in this folder.
COPY library-scripts /tmp/library-scripts
RUN bash /tmp/library-scripts/install base \
    && rm -rf /tmp/library-scripts
