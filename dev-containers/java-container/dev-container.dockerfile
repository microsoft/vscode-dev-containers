FROM maven:3.5-jdk-8-slim

# Install git
RUN apt-get update && apt-get -y install git \
  && rm -rf /var/lib/apt/lists/*