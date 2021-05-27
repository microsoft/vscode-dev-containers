#!/usr/bin/env bash
IMAGE_TO_TEST="${1:-default}"
INCLUDE_CODESPACES_TESTS="${1:-true}"
PRUNE_AFTER_TEST="${3:-true}"

set -e

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${SCRIPT_PATH}/../.."
run_test() {
    echo -e "\n\n***** 🌆 Testing image $1 *****\n🛠 Building image..."
    docker build -t vscdc-sshd-test-image --build-arg IMAGE_TO_TEST=$1 -f test/sshd/Dockerfile .
    echo '📦 Starting container...'
    if [ -f /workspaces/.codespaces/shared/.user-secrets.json ]; then
        EXTRA_ARGS="-v /workspaces/.codespaces/shared/.user-secrets.json:/workspaces/.codespaces/shared/.user-secrets.json:"
    else
        EXTRA_ARGS="-v ${SCRIPT_PATH}/test-user-secrets.json:/workspaces/.codespaces/shared/.user-secrets.json"
    fi
    if [ "${INCLUDE_CODESPACES_TESTS}" = "true" ]; then
        EXTRA_ARGS="${EXTRA_ARGS} -e CODESPACES=true"
    fi
    DOCKER_COMMAND="docker run --init --privileged --rm ${EXTRA_ARGS} vscdc-sshd-test-image /tmp/scripts/test-in-container.sh ${INCLUDE_CODESPACES_TESTS}"
    echo "Executing: $DOCKER_COMMAND" 
    eval $DOCKER_COMMAND
    if [ "${PRUNE_AFTER_TEST}" = "true" ]; then
        docker image rm vscdc-sshd-test-image
        docker system prune -f
    fi
    echo -e "\n💯 All tests for $1 passed!"
}

if [ "${IMAGE_TO_TEST}" = "default" ]; then
    run_test 'debian:buster'
    run_test 'debian:stretch'
    run_test 'ubuntu:focal'
    run_test 'ubuntu:bionic'
    run_test 'node:buster'
    run_test 'node:stretch'
    run_test 'python'
    run_test 'jupyter/datascience-notebook'
    run_test 'mcr.microsoft.com/vscode/devcontainers/base:buster'
    run_test 'mcr.microsoft.com/vscode/devcontainers/base:stretch'
    run_test 'mcr.microsoft.com/vscode/devcontainers/base:focal'
    run_test 'mcr.microsoft.com/vscode/devcontainers/base:bionic'
    run_test 'mcr.microsoft.com/vscode/devcontainers/javascript-node'
    run_test 'mcr.microsoft.com/azure-functions/python:3.0-python3.8-core-tools'
    run_test 'mcr.microsoft.com/vscode/devcontainers/universal'
else
    run_test "${IMAGE_TO_TEST}"
fi

echo -e "\n🎉 All test passed for all images!"
