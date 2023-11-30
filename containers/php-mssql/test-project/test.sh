#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Actual tests
checkExtension "xdebug.php-debug"
check "php" php --version

# Report result
reportResults
