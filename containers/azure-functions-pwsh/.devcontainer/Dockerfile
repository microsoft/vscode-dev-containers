# Find the Dockerfile for mcr.microsoft.com/azure-functions/powershell:3.0-powershell7-core-tools at this URL
# https://github.com/Azure/azure-functions-docker/blob/master/host/3.0/buster/amd64/powershell/powershell7-core-tools.Dockerfile

# Update the VARIANT arg in devcontainer.json to pick a supported PowerShell version: 7, 6
ARG VARIANT=7
FROM mcr.microsoft.com/azure-functions/powershell:3.0-powershell${VARIANT}-core-tools
