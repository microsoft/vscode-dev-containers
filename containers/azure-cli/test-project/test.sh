#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Run definition specific tests
checkExtension "ms-vscode.azurecli"
check "azure-cli" az --version

# Report result
reportResults
