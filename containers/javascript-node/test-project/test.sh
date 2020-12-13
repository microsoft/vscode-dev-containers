#!/bin/bash
cd $(dirname "$0")

source test-utils.sh node

# Run common tests
checkCommon

# Definition specific tests
checkExtension "dbaeumer.vscode-eslint"
check "node" node --version
check "yarn" yarn install
check "npm" npm install
check "eslint" "eslint server.js"
check "test-project" npm run test
check "nvm" bash -c "source /usr/local/share/nvm/nvm.sh && nvm install 8"
check "node" bash -c "source /usr/local/share/nvm/nvm.sh && node --version"

# Report result
reportResults
