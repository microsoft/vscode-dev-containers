FROM maven:3.6-jdk-8-slim

# Install git
RUN apt-get update && apt-get -y install git

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*
	