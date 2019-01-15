FROM maven:3.6-jdk-8-slim

# Install git
RUN apt-get update && apt-get -y install git \
  && rm -rf /var/lib/apt/lists/*