# [Choice] R version: 4, 4.1, 4.0
ARG VARIANT=4
# [Choice] Base image. Minimal (r-ver), tidyverse installed (tidyverse), or full image (binder): rocker/r-ver, rocker/tidyverse, rocker/binder
ARG BASE_IMAGE=rocker/r-ver
FROM ${BASE_IMAGE}:${VARIANT}

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=rstudio
ARG USER_UID=1000
ARG USER_GID=$USER_UID
USER root
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && usermod -a -G staff ${USERNAME} \
    && apt-get -y install \
        python3-pip \
        libgit2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        libxt-dev \
        libfontconfig1-dev \
        libcairo2-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts \
    && python3 -m pip --no-cache-dir install radian \
    && install2.r --error --skipinstalled --ncpus -1 \
        devtools \
        languageserver \
        httpgd \
    && rm -rf /tmp/downloaded_packages

# VSCode R Debugger dependency. Install the latest release version from GitHub without using GitHub API.
# See https://github.com/microsoft/vscode-dev-containers/issues/1032
RUN export TAG=$(git ls-remote --tags --refs --sort='version:refname' https://github.com/ManuelHentschel/vscDebugger v\* | tail -n 1 | cut --delimiter='/' --fields=3) \
    && Rscript -e "remotes::install_git('https://github.com/ManuelHentschel/vscDebugger.git', ref = '"${TAG}"', dependencies = FALSE)"

# R Session watcher settings.
# See more details: https://github.com/REditorSupport/vscode-R/wiki/R-Session-watcher
RUN echo 'source(file.path(Sys.getenv("HOME"), ".vscode-R", "init.R"))' >> ${R_HOME}/etc/Rprofile.site

# [Option] Enable vscode-jupyter support
ARG ENABLE_JUPYTER="false"
RUN if [ "${ENABLE_JUPYTER}" = "true" ]; then \
        if [ -z "$(dpkg --get-selections | grep libzmq3-dev)" ]; then \
            apt-get update \
            && export DEBIAN_FRONTEND=noninteractive \
            && apt-get -y install --no-install-recommends libzmq3-dev \
            && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*; \
        fi \
        && install2.r --error --skipinstalled --ncpus -1 IRkernel \
        && rm -rf /tmp/downloaded_packages \
        && python3 -m pip --no-cache-dir install jupyter \
        && R --vanilla -s -e 'IRkernel::installspec(user = FALSE)'; \
    fi

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this section to install additional R packages.
# RUN install2.r --error --skipinstalled --ncpus -1 <your-package-list-here>
