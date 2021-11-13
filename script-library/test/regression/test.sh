#!/usr/bin/env bash
IMAGE_TO_TEST="${1:-debian}"
RUN_ONE="${2:-false}" # false or script name
USE_DEFAULTS="${3:-true}"
RUN_COMMON_SCRIPT="${4:-true}"
PLATFORMS="$5"

set -e

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../.."
echo -e  "🧪 Testing image $IMAGE_TO_TEST..."

if [ -z "${PLATFORMS}" ]; then
    OTHER_ARGS="--load"
else
    CURRENT_BUILDERS="$(docker buildx ls)"
    if [[ "${CURRENT_BUILDERS}" != *"vscode-dev-containers"* ]]; then
        docker buildx create --use --name vscode-dev-containers
    else
        docker buildx use vscode-dev-containers
    fi

    docker run --privileged --rm tonistiigi/binfmt --install all
    OTHER_ARGS="--builder vscode-dev-containers --platform ${PLATFORMS}"
fi

if [ "${USE_DEFAULTS}" = "false" ]; then
    dockerfile_path="test/regression/alt.Dockerfile"
else
    dockerfile_path="test/regression/Dockerfile"
fi

BUILDX_COMMAND="docker buildx build \
    ${OTHER_ARGS} \
    --progress=plain \
    --build-arg IMAGE_TO_TEST=$IMAGE_TO_TEST \
    --build-arg RUN_ONE=${RUN_ONE} \
    --build-arg RUN_COMMON_SCRIPT=${RUN_COMMON_SCRIPT} \
    -t vscdc-script-library-regression \
    -f ${dockerfile_path} \
    ."
echo $BUILDX_COMMAND
$BUILDX_COMMAND

# If we've loaded the image into docker, run it to make sure it starts properly
if [ -z "${PLATFORMS}" ]; then
    docker run --init --privileged --rm vscdc-script-library-regression bash -c 'uname -m && env'
fi

echo -e "\n🎉 All tests passed!"
