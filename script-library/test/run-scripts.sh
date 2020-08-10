#!/bin/sh

SCRIPT_DIR=${1-"/tmp"}
DISTRO=${2:-debian}
USE_DEFAULTS=${3:-true}
USERNAME=${4:-vscode}
UPGRADE_PAGKES=${5:-true}
ENABLE_NONROOT=${6:-true}
NODE_VERSION=${7:-"lts/*"}
MAVEN_VERSION=${8:-"3.6.3"}
MAVEN_DOWNLOAD_SHA=${9:-"c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0"}
GRADLE_VERSION=${10:-"5.4.1"}
GRADLE_DOWNLOAD_SHA=${11:-"7bdbad1e4f54f13c8a78abc00c26d44dd8709d4aedb704d913fb1bb78ac025dc"}
TERRAFORM_VERSION=${12:-"0.12.16"}
TFLINT_VERSION=${13:-"0.8.2"}

runScript()
{
    SCRIPT=$1
    ARGS=$2
    REQUIRED_PREFIX_ARGS=${3:-""}
    echo "**** Testing $SCRIPT ****"
    if [ "${USE_DEFAULTS}" = "true" ]; then
        echo "Using defaults..."
        ${SCRIPT} ${REQUIRED_PREFIX_ARGS}
    else
        echo "Arguments: ${REQUIRED_PREFIX_ARGS} ${ARGS}"
        ${SCRIPT} ${REQUIRED_PREFIX_ARGS} ${ARGS}
    fi
    echo "**** Done! ****\n"
}

runScript ${SCRIPT_DIR}/common-${DISTRO}.sh "true ${USERNAME} 1000 1000 ${UPGRADE_PACKAGES}"

if [ "${DISTRO}" = "debian" ]; then
    runScript ${SCRIPT_DIR}/node-${DISTRO}.sh "/usr/local/share/nvm ${NODE_VERSION} ${USERNAME}"
    runScript ${SCRIPT_DIR}/maven-${DISTRO}.sh "/usr/local/share/maven ${USERNAME} ${MAVEN_DOWNLOAD_SHA}" "${MAVEN_VERSION}"
    runScript ${SCRIPT_DIR}/gradle-${DISTRO}.sh "/usr/local/share/gradle ${USERNAME} ${GRADLE_DOWNLOAD_SHA}" "${GRADLE_VERSION}"
    runScript ${SCRIPT_DIR}/terraform-${DISTRO}.sh "${TFLINT_VERSION}" "${TERRAFORM_VERSION}"
fi

# Run Docker script
if  [ "${DISTRO}" != "alpine" ]; then
    runScript /tmp/docker-${DISTRO}.sh "true /var/run/docker-host.sock /var/run/docker.sock ${USERNAME}"
else
    echo '#!/bin/bash\n"$@"' | tee /usr/local/share/docker-init.sh
    chown ${USERNAME} /usr/local/share/docker-init.sh
    chmod +x /usr/local/share/docker-init.sh
fi
