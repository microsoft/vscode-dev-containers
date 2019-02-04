FROM microsoft/dotnet:2.2-sdk

RUN apt-get update

RUN apt-get -y install git libunwind8