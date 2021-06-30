#!/bin/bash
cd $(dirname "$0")

source test-utils.sh node

# Remote - Containers does not auto-sync UID/GID for Docker Compose,
# so make sure test project prvs match the non-root user in the container.
fixTestProjectFolderPrivs

# Run common tests
checkCommon

# Definition specific tests
checkExtension "dbaeumer.vscode-eslint"
checkExtension "ms-azuretools.vscode-dapr",
checkExtension "ms-azuretools.vscode-docker",
dapr uninstall # May have already been run
check "dapr" dapr init
check "node" node --version
sudo rm -f package-lock.json
check "yarn" yarn install
sudo rm -f yarn.lock
check "npm" npm install
check "eslint" eslint src/server.ts
check "typescript" npm run compile
check "test-project" npm run test
check "nvm" bash -c ". /usr/local/share/nvm/nvm.sh && nvm install 8"
check "nvm-node" bash -c ". /usr/local/share/nvm/nvm.sh && node --version"
sudo rm -rf node_modules

# Report result
reportResults
