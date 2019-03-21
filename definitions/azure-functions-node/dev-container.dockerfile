FROM microsoft/dotnet:2.1-sdk-stretch

# Install required tools

RUN apt-get update \
    && apt-get install -y git apt-transport-https curl \
    && curl -sSL https://deb.nodesource.com/setup_8.x | bash - \
    && curl -sSO https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y nodejs \
    && apt-get download azure-functions-core-tools \
    && dpkg -i --force-depends azure-functions-core-tools*.deb \
    && rm azure-functions-core-tools*.deb \
	&& rm -rf /var/lib/apt/lists/*
