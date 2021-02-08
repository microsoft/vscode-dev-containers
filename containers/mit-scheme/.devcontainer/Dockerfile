# [Choice] Debian version: buster, stretch
ARG VARIANT_DEBIAN="buster"
FROM buildpack-deps:${VARIANT_DEBIAN}-curl

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"


# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/common-debian.sh /tmp/library-scripts/
RUN bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Install MIT-Scheme
ARG TARGET_SCHEME_VERSION="11.1"
ARG TARGET_SCHEME_PATH="/usr/local/mit-scheme"
COPY mit-scheme-debian.sh /tmp/library-scripts/
RUN bash /tmp/library-scripts/mit-scheme-debian.sh "${TARGET_SCHEME_VERSION}" "${TARGET_SCHEME_PATH}" "${USERNAME}" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>