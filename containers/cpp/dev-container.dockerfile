FROM ubuntu:1804

# Install git
RUN apt-get update && apt-get -y install git

# Install C++ tools
RUN apt-get -y install build-essential cmake cppcheck valgrind

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
