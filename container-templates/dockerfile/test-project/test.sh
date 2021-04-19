#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Run definition specific tests

# checkExtension "<Extension ID goes here>"
# check "<label>" command goes here
# checkOSPackages  "<label>" package list goes here
# checkMultiple "<label>" condition1 condition2

# Report result
reportResults
