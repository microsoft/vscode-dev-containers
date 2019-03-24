FROM google/dart:2

ENV PATH="$PATH":"/root/.pub-cache/bin"

RUN pub global activate webdev

# Install git
RUN apt-get update && apt-get -y install git

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
	
