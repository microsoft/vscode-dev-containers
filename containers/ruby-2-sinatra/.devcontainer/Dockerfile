FROM debian:latest

# Install vim, git, process tools
RUN apt-get update \
    && apt-get install -y \
        vim \
        git \
        procps

# Install ruby
RUN apt-get install -y \
        ruby \
        ruby-dev \
        build-essential \
        libsqlite3-dev

# Install debug tools
RUN gem install \
        rake \
        ruby-debug-ide \
        debase

# Install sinatra MVC components
RUN gem install \
        sinatra \
        sinatra-reloader \
        thin \
        data_mapper \
        dm-sqlite-adapter

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Set the default shell to bash instead of sh
ENV SHELL /bin/bash