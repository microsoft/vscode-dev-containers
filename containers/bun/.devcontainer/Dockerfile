FROM --platform=linux/amd64 mcr.microsoft.com/vscode/devcontainers/base:0-bullseye

ENV BUN_INSTALL=/bun

RUN mkdir -p /bun \
    && curl https://bun.sh/install | bash \
    && chown -R vscode /bun

ENV PATH=${BUN_INSTALL}/bin:${PATH}

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
