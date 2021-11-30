#!/bin/bash
DEFINITION="$1"

set -e

export DOCKER_BUILDKIT=1

# Symlink build scripts from main to improve security when testing PRs
if [ -d "$GITHUB_WORKSPACE/__build/build" ]; then
    cp -r "$GITHUB_WORKSPACE/__build/build" "$GITHUB_WORKSPACE/"
else
    echo "WARNING: Using build/vscdc from $GITHUB_REF instead of main."
fi
rm -rf node_modules
yarn install

# Run test build
chmod +x build/vscdc
build/vscdc push  ${DEFINITION} \
    --no-push \
    --release dev \
    --github-repo "microsoft/vscode-dev-containers" \
    --registry "mcr.microsoft.com" \
    --registry-path "vscode/devcontainers" \
    --stub-registry "mcr.microsoft.com" \
    --stub-registry-path "vscode/devcontainers"
