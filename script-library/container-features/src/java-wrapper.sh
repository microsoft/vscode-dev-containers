#!/usr/bin/env bash
# Wrapper function that also installs JDK 11 if JDK 8 is selected since this is required for the Java extension

set -e

JAVA_VERSION=${1:-"default"}
SDKMAN_DIR=${2:-"/usr/local/sdkman"}
USERNAME=${3:-"automatic"}
UPDATE_RC=${4:-"true"}
ADDITIONAL_JAVA_VERSION=11

# If the user selected JDK 8, install the JDK 11 as well - update settings
if echo "${JAVA_VERSION}" | grep -E '^8([\s\.]|$)' > /dev/null 2>&1; then
    echo "(*) Installing secondary JDK since the Java VS Code extension requires a more recent version..."
    /tmp/build-features/java-debian.sh "${ADDITIONAL_JAVA_VERSION}" "${SDKMAN_DIR}" "${USERNAME}" "${UPDATE_RC}"
    jdk_11_folder=$(ls --format=single-column /usr/local/sdkman/candidates/java | grep -oE -m 1 '11\..+')
    ln -s /usr/local/sdkman/candidates/java/${jdk_11_folder} /extension-java-home

    # Determine the appropriate non-root user
    username=""
    possible_users=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for current_user in ${possible_users[@]}; do
        if id -u ${current_user} > /dev/null 2>&1; then
            username=${current_user}
            break
        fi
    done
    if [ "${username}" = "" ]; then
        username=root
    fi
else
    ln -s /usr/local/sdkman/candidates/java/current /extension-java-home
fi

echo "(*) Installing JDK ${JAVA_VERSION}..."
/tmp/build-features/java-debian.sh "${JAVA_VERSION}" "${SDKMAN_DIR}" "${USERNAME}" "${UPDATE_RC}"

# Create a symlink for each installed JDK version
ls --format=single-column /usr/local/sdkman/candidates/java | xargs 