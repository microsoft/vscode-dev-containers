#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Remote - Containers does not auto-sync UID/GID for Docker Compose,
# so make sure test project prvs match the non-root user in the container.
fixTestProjectFolderPrivs

# Run common tests
checkCommon

# Definition specific tests
checkExtension "ms-azuretools.vscode-dapr",
checkExtension "ms-azuretools.vscode-docker",
checkExtension "ms-dotnettools.csharp"
dapr uninstall # May have already been run
check "dapr" dapr init
check "dotnet" dotnet --info
check "nuget" dotnet restore
check "msbuild" dotnet msbuild
sudo rm -rf obj bin

# Report result
reportResults
