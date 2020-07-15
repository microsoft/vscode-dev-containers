FROM openjdk:8

# install git iproute2
RUN apt-get update && apt-get -y install git iproute2

# https support
RUN apt-get install apt-transport-https

# get gcc
RUN apt-get update &&apt-get install build-essential -y

# Install Node.js v10-stable
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - 2>/dev/null \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install yarn=1.13.0-1

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
