#!/usr/bin/env bash
INCLUDE_CODESPACES_TESTS="${1:-false}"

set -e

cd "$(cd "$(dirname "$0")" && pwd)/../.."
run_test() {
    echo -e "\n\n***** 🌆 Testing image $1 *****\n🛠 Building image..."
    docker build -t vscdc-ssd-test-image --build-arg IMAGE_TO_TEST=$1 -f test/sshd/Dockerfile .
    echo '📦 Starting container...'
    docker run -u root --rm vscdc-ssd-test-image /tmp/scripts/test-in-container.sh ${INCLUDE_CODESPACES_TESTS}
    echo -e "\n💯 All tests for $1 passed!"
}

run_test 'mcr.microsoft.com/vscode/devcontainers/base:0-focal'