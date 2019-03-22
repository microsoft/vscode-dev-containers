FROM python:3.7-slim

# Install required tools
RUN apt-get update \
	&& apt-get install -y git 

# Install Docker CE - ** COMMENT OUT IF YOU WILL ONLY RUN LOCAL OR IN AZURE **
RUN apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli

# Install pylint
RUN pip install pylint

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*
