FROM ubuntu:latest

RUN apt-get update

RUN apt-get -y install git

RUN apt-get -y install build-essential cmake cppcheck valgrind

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*
