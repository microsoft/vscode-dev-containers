FROM rust:1.32

RUN rustup update
RUN rustup component add rls rust-analysis rust-src

# Install required tools
RUN apt update && apt install -y \
  git \
  lldb-3.9 \
  && rm -rf /var/lib/apt/lists/*
