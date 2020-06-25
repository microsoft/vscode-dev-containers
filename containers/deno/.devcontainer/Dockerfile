FROM mcr.microsoft.com/vscode/devcontainers/base:debian-10

ENV DENO_INSTALL=/deno
RUN mkdir -p /deno \
    && chown -R vscode /deno \
    && curl -fsSL https://deno.land/x/install/install.sh | sh

ENV PATH=${DENO_INSTALL}/bin:${PATH} \
    DENO_DIR=${DENO_INSTALL}/.cache/deno
