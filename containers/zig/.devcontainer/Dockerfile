# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.245.0/containers/alpine/.devcontainer/base.Dockerfile

# [Choice] Alpine version: 3.16, 3.15, 3.14, 3.13
ARG VARIANT="3.16"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-alpine-${VARIANT}

RUN apk --no-cache add git

ADD https://ziglang.org/builds/zig-linux-x86_64-0.10.0-dev.3857+10e11b60e.tar.xz /zig.tar.xz
RUN tar -xvf /zig.tar.xz && mv /zig-linux-x86_64-0.10.0-dev.3857+10e11b60e /zig && chown -R vscode /zig
ENV PATH="/zig:${PATH}"

# [Optional] Uncomment this section to install gyro package manager
# ADD https://github.com/mattnite/gyro/releases/download/0.7.0/gyro-0.7.0-linux-x86_64.tar.gz /gyro.tar.gz
# RUN tar -xvf /gyro.tar.gz && mv /gyro-0.7.0-linux-x86_64 /gyro && chown -R vscode /gyro
# ENV PATH="/gyro/bin:${PATH}"

# ** [Optional] Uncomment this section to install additional packages. **
# RUN apk update \
#     && apk add --no-cache <your-package-list-here>
