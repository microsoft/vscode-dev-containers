FROM mcr.microsoft.com/vscode/devcontainers/repos/microsoft/vscode:latest

COPY fluxbox/* /tmp/fluxbox/
COPY *.sh /tmp/scripts/
RUN bash /tmp/scripts/install.sh \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/scripts/ /tmp/fluxbox/ \
    && git config --global codespaces-theme.hide-status 1
