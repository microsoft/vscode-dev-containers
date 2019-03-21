FROM microsoft/dotnet:2.2-sdk

RUN apt-get update

RUN apt-get -y install git libunwind8

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*
