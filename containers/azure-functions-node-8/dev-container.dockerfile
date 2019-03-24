FROM microsoft/dotnet:2.1-sdk-stretch

# Install git
RUN apt-get update && apt-get -y install git

# Install Node.js
RUN apt-get install -y curl \
    && curl -sSL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs 

# Install Azure Functions
RUN apt-get install -y apt-transport-https \
    && curl -sSO https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get download azure-functions-core-tools \
    && dpkg -i --force-depends azure-functions-core-tools*.deb \
    && rm azure-functions-core-tools*.deb

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
