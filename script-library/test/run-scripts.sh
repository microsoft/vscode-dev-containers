#!/bin/sh

SCRIPT_DIR=${1-"/tmp"}
DISTRO=${2:-"debian"}
USE_DEFAULTS=${3:-"true"}
USERNAME=${4:-"vscode"}
RUN_COMMON_SCRIPT=${5:-"true"}
UPGRADE_PAGKES=${6:-"true"}

set -e

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

if [ "${RUN_COMMON_SCRIPT}" = "true" ]; then
    runScript ${SCRIPT_DIR}/common-${DISTRO}.sh "true ${USERNAME} 1000 1000 ${UPGRADE_PACKAGES}"
fi

if [ "${DISTRO}" = "debian" ]; then
    runScript ${SCRIPT_DIR}/azcli-${DISTRO}.sh
    runScript ${SCRIPT_DIR}/git-from-src-${DISTRO}.sh "2.26.2"
    runScript ${SCRIPT_DIR}/git-lfs-${DISTRO}.sh
    runScript ${SCRIPT_DIR}/github-${DISTRO}.sh
    runScript ${SCRIPT_DIR}/go-${DISTRO}.sh "1.14 /opt/go /go ${USERNAME} false"
    runScript ${SCRIPT_DIR}/gradle-${DISTRO}.sh "/usr/local/share/gradle ${USERNAME} 7bdbad1e4f54f13c8a78abc00c26d44dd8709d4aedb704d913fb1bb78ac025dc" "5.4.1"
    runScript ${SCRIPT_DIR}/java-${DISTRO}.sh "8 /usr/local/share/java ${USERNAME} false"
    runScript ${SCRIPT_DIR}/kubectl-helm-${DISTRO}.sh
    runScript ${SCRIPT_DIR}/maven-${DISTRO}.sh "/usr/local/share/maven ${USERNAME} c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0" "3.6.3"
    runScript ${SCRIPT_DIR}/node-${DISTRO}.sh "/usr/local/share/nvm 10 ${USERNAME}"
    runScript ${SCRIPT_DIR}/powershell-${DISTRO}.sh
    runScript ${SCRIPT_DIR}/rust-${DISTRO}.sh "/opt/rust/cargo /opt/rust/rustup ${USERNAME} false"
    runScript ${SCRIPT_DIR}/terraform-${DISTRO}.sh "0.12.16" "0.8.2"
fi

# Run Docker script
if  [ "${DISTRO}" != "alpine" ]; then
    runScript /tmp/docker-${DISTRO}.sh "true /var/run/docker-host.sock /var/run/docker.sock ${USERNAME}"
else
    echo '#!/bin/bash\n"$@"' | tee /usr/local/share/docker-init.sh
    chown ${USERNAME} /usr/local/share/docker-init.sh
    chmod +x /usr/local/share/docker-init.sh
fi
