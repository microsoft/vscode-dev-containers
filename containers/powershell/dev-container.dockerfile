FROM microsoft/powershell

# Install required tools
RUN apt-get update \
	&& apt-get install -y git

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
