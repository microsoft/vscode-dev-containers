FROM microsoft/dotnet:2.2-sdk

# Install git
RUN apt-get update && apt-get -y install git

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
