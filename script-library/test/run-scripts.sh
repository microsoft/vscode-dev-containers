#!/bin/sh

SCRIPT_DIR=${1-"/tmp"}
DISTRO=${2:-"debian"}
USE_DEFAULTS=${3:-"true"}
USERNAME=${4:-"vscode"}
RUN_COMMON_SCRIPT=${5:-"true"}
UPGRADE_PACKAGES=${6:-"true"}

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
    runScript ${SCRIPT_DIR}/fish-${DISTRO}.sh "false ${USERNAME}"
    runScript ${SCRIPT_DIR}/git-from-src-${DISTRO}.sh "2.26.2"
    runScript ${SCRIPT_DIR}/git-lfs-${DISTRO}.sh
    runScript ${SCRIPT_DIR}/github-${DISTRO}.sh
    runScript ${SCRIPT_DIR}/go-${DISTRO}.sh "1.14 /opt/go /go ${USERNAME} false"
    runScript ${SCRIPT_DIR}/gradle-${DISTRO}.sh "4.4 /usr/local/sdkman1 ${USERNAME} false"
    runScript ${SCRIPT_DIR}/homebrew-${DISTRO}.sh "${USERNAME} false true /home/${USERNAME}/linuxbrew"
    runScript ${SCRIPT_DIR}/java-${DISTRO}.sh "13.0.2.j9-adpt /usr/local/sdkman2 ${USERNAME} false"
    runScript ${SCRIPT_DIR}/kubectl-helm-${DISTRO}.sh
    runScript ${SCRIPT_DIR}/maven-${DISTRO}.sh "3.6.3 /usr/local/sdkman3 ${USERNAME} false" 
    runScript ${SCRIPT_DIR}/node-${DISTRO}.sh "/usr/local/share/nvm 10 ${USERNAME}"
    runScript ${SCRIPT_DIR}/powershell-${DISTRO}.sh
    runScript ${SCRIPT_DIR}/python-${DISTRO}.sh "3.4.10 /opt/python ${USERNAME} false false"
    runScript ${SCRIPT_DIR}/ruby-${DISTRO}.sh "${USERNAME} false" "2.5.8"
    runScript ${SCRIPT_DIR}/rust-${DISTRO}.sh "/opt/rust/cargo /opt/rust/rustup ${USERNAME} false"
    runScript ${SCRIPT_DIR}/terraform-${DISTRO}.sh "0.12.16" "0.8.2"
    runScript ${SCRIPT_DIR}/sshd-${DISTRO}.sh "2223 ${USERNAME} true random"
    runScript ${SCRIPT_DIR}/desktop-lite-${DISTRO}.sh "${USERNAME} changeme false"
fi

# Run Docker script
if  [ "${DISTRO}" != "alpine" ]; then
    runScript /tmp/docker-${DISTRO}.sh "true /var/run/docker-host.sock /var/run/docker.sock ${USERNAME}"
else
    echo '#!/bin/bash\n"$@"' | tee /usr/local/share/docker-init.sh
    chown ${USERNAME} /usr/local/share/docker-init.sh
    chmod +x /usr/local/share/docker-init.sh
fi
