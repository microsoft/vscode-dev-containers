FROM node:8-slim

# Install git
RUN apt-get update && apt-get -y install git

# Install eslint
RUN npm install -g eslint

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
