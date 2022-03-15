#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Remote - Containers does not auto-sync UID/GID for Docker Compose,
# so make sure test project prvs match the non-root user in the container.
fixTestProjectFolderPrivs

# Run common tests
checkCommon

# Actual tests
checkExtension "jakebecker.elixir-ls"
check "elixir" iex --version
. /usr/local/share/nvm/nvm.sh
check "nvm" nvm install 16
check "node" node --version
check "npm" npm --version
check "build test project" echo yes | mix phx.new example --live
check "download deps" cd ./example && mix deps.get && mix deps.compile
# Hex only installed for non-root user, so skip phoenix test for root
if [ "$(id -u)" != "0" ]; then
    check "phoenix" mix test --force
fi
rm -rf example

# Report result
reportResults