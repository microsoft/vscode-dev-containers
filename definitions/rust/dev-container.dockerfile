FROM rust:1

RUN rustup update
RUN rustup component add rls rust-analysis rust-src

# Install git
RUN apt-get update && apt-get -y install git

# Install other dependencies
RUN apt-get install lldb-3.9

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*
