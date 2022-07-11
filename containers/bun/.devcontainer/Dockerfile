# [Choice] Debian OS version: bullseye, buster
ARG VARIANT=bullseye
FROM --platform=linux/amd64 mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

ENV BUN_INSTALL=/bun
RUN mkdir -p /bun \
    && curl -fsSL https://bun.sh/install | sh \
    && chown -R vscode /bun

ENV PATH=${BUN_INSTALL}/bin:${PATH} \
    BUN_DIR=${BUN_INSTALL}/.cache/bun

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#    && apt-get -y install --no-install-recommends <your-package-list-here>
