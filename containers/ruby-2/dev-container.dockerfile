FROM ruby:2

# Install ruby-debug-ide and debase
RUN gem install ruby-debug-ide
RUN gem install debase

# Install git
RUN apt-get update && apt-get -y install git

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
	
