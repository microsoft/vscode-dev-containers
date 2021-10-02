#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Definition specific tests
checkExtension "golang.go"
check "go-build" go build

# Clean up
rm -f test-project

# Report result
reportResults
