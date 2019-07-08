FROM ruby:2

RUN gem install ruby-debug-ide
RUN gem install debase

ADD https://apt.puppetlabs.com/puppet6-release-xenial.deb /puppet6-release-xenial.deb
RUN dpkg -i /puppet6-release-xenial.deb

RUN apt-get update \
    && apt-get -y install git procps pdk

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
