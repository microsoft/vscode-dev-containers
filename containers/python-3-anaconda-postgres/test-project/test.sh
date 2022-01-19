#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Remote - Containers does not auto-sync UID/GID for Docker Compose,
# so make sure test project prvs match the non-root user in the container.
fixTestProjectFolderPrivs

# Run common tests
checkCommon

# Definition specific tests
checkExtension "ms-python.python"
checkExtension "ms-python.vscode-pylance"
checkExtension "mtxr.sqltools"
checkExtension "mtxr.sqltools-driver-pg"
check "python" python --version
check "test-project" python ./hello.py
check "plot.png" wc ./plot.png

# Clean up
rm plot.png

# Report result
reportResults
