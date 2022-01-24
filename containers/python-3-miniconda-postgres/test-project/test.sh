#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Definition specific tests
checkExtension "ms-python.python"
checkExtension "ms-python.vscode-pylance"
check "python" python --version
check "test-project: database.py" python ./database.py
check "test-project: plot.py" python ./plot.py
check "test-project: plot.png created" test -f ./plot.png

# Clean up
rm plot.png

# Report result
reportResults
