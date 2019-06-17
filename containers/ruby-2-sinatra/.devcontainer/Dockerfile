FROM debian:latest

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1 \
    #
    # Install vim, git, process tools, lsb-release
    && apt-get install -y \
        vim \
        git \
        procps \
        lsb-release \
    #
    # Install ruby
    && apt-get install -y \
        ruby \
        ruby-dev \
        build-essential \
        libsqlite3-dev \
    #
    # Install debug tools
    && gem install \
        rake \
        ruby-debug-ide \
        debase \
    #
    # Install sinatra MVC components
    && gem install \
        sinatra \
        sinatra-reloader \
        thin \
        data_mapper \
        dm-sqlite-adapter \
    #
    # Clean up
    && apt-get autoremove -y \
        && apt-get clean -y \
        && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog