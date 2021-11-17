#!/bin/bash
DEFINITION="$1"

set -e

export DOCKER_BUILDKIT=1

# Symlink build scripts from main to improve security when testing PRs
if [ -d "$GITHUB_WORKSPACE/__build/build" ]; then
    cd "$GITHUB_WORKSPACE/__build"
    yarn install
    cd "$GITHUB_WORKSPACE"
    rm -rf build node_modules
    ln -s "$GITHUB_WORKSPACE/__build/build" build
    ln -s "$GITHUB_WORKSPACE/__build/node_modules" node_modules
else
    echo "WARNING: Using build/vscdc from $GITHUB_REF instead of main."
    yarn install
fi

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
