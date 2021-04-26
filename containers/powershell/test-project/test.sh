#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Actual tests
checkExtension "ms-vscode.powershell"
check "powershell" pwsh hello.ps1

# Report result
reportResults
