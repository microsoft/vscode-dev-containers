#!/usr/bin/env bash
IMAGE_TO_TEST="${1:-"mcr.microsoft.com/vscode/devcontainers/base:bullseye"}"
PLATFORMS="${2:-""}"
SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

set -e

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/stage.sh"
cp -f test-features.env out/devcontainer-features.env

if [ ! -z "${PLATFORMS}" ]; then
    CURRENT_BUILDERS="$(docker buildx ls)"
    if [[ "${CURRENT_BUILDERS}" != *"vscode-dev-containers"* ]]; then
        docker buildx create --use --name vscode-dev-containers
    else
        docker buildx use vscode-dev-containers
    fi

    docker run --privileged --rm tonistiigi/binfmt --install ${PLATFORMS}
    PLATFORMS_ARG="--builder vscode-dev-containers --platform ${PLATFORMS}"
fi
docker buildx build --progress plain --load ${PLATFORMS_ARG} --build-arg BASE_IMAGE=$IMAGE_TO_TEST -t container-features-regression -f test.Dockerfile out
docker run --init --privileged container-features-regression bash -c 'uname -m && env'

# Remove devcontainer-features.env from out folder so we can use it to test the VS Code extension
rm -f out/devcontainer-features.env

echo -e "\n🎉 All tests passed!"
