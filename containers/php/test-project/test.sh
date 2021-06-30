#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Actual tests
checkExtension "felixfbecker.php-debug"
checkExtension "felixfbecker.php-intellisense"
checkExtension "mrmlnc.vscode-apache"
check "php" php --version
check "apache2ctl" which apache2ctl

# Report result
reportResults
