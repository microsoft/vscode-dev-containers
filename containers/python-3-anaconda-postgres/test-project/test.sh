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
check "python" python --version
python ./hello.py > out.txt
check "test-project: plot.png" test -f ./plot.png
check "test-project: database" grep -qF "DATABASE CONNECTED" out.txt

# Clean up
rm plot.png out.txt

# Report result
reportResults
