#!/usr/bin/env bash
RUN_CODESPACES_TESTS=${1:-false}

cd "$(cd "$(dirname "$0")" && pwd)"
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

./test-in-container-for-user.sh root $RUN_CODESPACES_TESTS
USERNAME="$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd 2>/dev/null)"
if [ "${USERNAME}" != "" ]; then
    su $USERNAME -c ./test-in-container-for-user.sh $USERNAME $RUN_CODESPACES_TESTS
fi

echo -e "\n🙌 Tests passed for all users!"
