#!/usr/bin/env bash
# Wrapper function that also installs JDK 11 if JDK 8 is selected since this is required for the Java extension

set -e

JAVA_VERSION=${1:-"default"}
SDKMAN_DIR=${2:-"/usr/local/sdkman"}
USERNAME=${3:-"automatic"}
UPDATE_RC=${4:-"true"}
ADDITIONAL_JAVA_VERSION=11

/tmp/library-scripts/java-debian.sh "${JAVA_VERSION}" "${SDKMAN_DIR}" "${USERNAME}" "${UPDATE_RC}"

# If the user selected JDK 8, install the JDK 11 as well
if echo "${JAVA_VERSION}" | grep -E '^8([\s\.]|$)' > /dev/null 2>&1; then
    /tmp/library-scripts/java-debian.sh "${ADDITIONAL_JAVA_VERSION}" "${SDKMAN_DIR}" "${USERNAME}" "${UPDATE_RC}"
fi
