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
check "eslint" eslint --no-eslintrc -c .eslintrc.json src/server.ts
check "typescript" npm run compile
check "test-project" npm run test
check "nvm" bash -c ". /usr/local/share/nvm/nvm.sh && nvm install 8"
check "nvm-node" bash -c ". /usr/local/share/nvm/nvm.sh && node --version"
sudo rm -rf node_modules out yarn.lock package-lock.json

# Report result
reportResults
