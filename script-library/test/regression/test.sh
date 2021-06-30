#!/usr/bin/env bash
IMAGE_TO_TEST="${1:-debian}"

if [ "$IMAGE_TO_TEST" = "centos" ]; then
    DISTRO="redhat"
elif [ "${IMAGE_TO_TEST}" = "ubuntu" ]; then
    DISTRO="debian"
else
    DISTRO=$IMAGE_TO_TEST
fi

set -e

cd "$(cd "$(dirname "$0")" && pwd)/../.."
echo -e  "🧪 Testing image $IMAGE_TO_TEST (${DISTRO}-like)..."
docker build --build-arg DISTRO=$DISTRO --build-arg IMAGE_TO_TEST=$IMAGE_TO_TEST -f test/regression/Dockerfile .
echo -e "\n🎉 All tests passed!"
