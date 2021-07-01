FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get -y update && apt-get -yq install git python3 build-essential \
    ccache gdb lcov libbz2-dev libffi-dev libgdbm-dev liblzma-dev \
    libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
    lzma lzma-dev tk-dev uuid-dev xvfb zlib1g-dev \
     && apt-get clean -y && rm -rf /var/lib/apt/lists/*
