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
check "build test project" echo yes | mix new example
check "download deps" cd ./example && mix deps.get && mix deps.compile
rm -rf example

# Report result
reportResults
