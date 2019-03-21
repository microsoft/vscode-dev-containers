FROM ruby:2.5

# Install ruby-debug-ide and debase
RUN gem install ruby-debug-ide
RUN gem install debase

# Install git
RUN apt-get update && apt-get -y install git \
&& rm -rf /var/lib/apt/lists/*