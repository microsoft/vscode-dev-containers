#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Definition specific tests
checkExtension "ms-dotnettools.csharp"
check "dotnet" dotnet --info
check "nuget" dotnet restore
check "msbuild" dotnet msbuild
check "nvm" bash -c ". /usr/local/share/nvm/nvm.sh && nvm install 10"
check "nvm-node" bash -c ". /usr/local/share/nvm/nvm.sh && node --version"
check "yarn" yarn install

# Report result
reportResults