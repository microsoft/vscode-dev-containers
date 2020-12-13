#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Definition specific tests
checkExtension "julialang.language-julia"
check "julia" julia --version

# Report result
reportResults
