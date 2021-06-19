#!/bin/sh

SCRIPT_DIR=${1-"/tmp"}
DISTRO=${2:-"debian"}
USE_DEFAULTS=${3:-"true"}
USERNAME=${4:-"vscode"}
RUN_COMMON_SCRIPT=${5:-"true"}
UPGRADE_PACKAGES=${6:-"true"}
RUN_ONE=${7:-"false"} # false or script name

set -e

runScript()
{
    SCRIPT_NAME=$1
    if [ "${RUN_ONE}" != "false" ] && [ "${RUN_ONE}" != "common" ] && [ "${SCRIPT_NAME}" != "${RUN_ONE}" ]; then
        return
    fi
    SCRIPT=${SCRIPT_DIR}/${SCRIPT_NAME}-${DISTRO}.sh
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
    runScript common "true ${USERNAME} 1000 1000 ${UPGRADE_PACKAGES}"
fi

if [ "${DISTRO}" = "debian" ]; then
    runScript azcli
    runScript fish "false ${USERNAME}"
    runScript git-from-src "2.26.2"
    runScript git-lfs
    runScript github
    runScript go "1.14 /opt/go /go ${USERNAME} false"
    runScript gradle "4.4 /usr/local/sdkman1 ${USERNAME} false"
    runScript homebrew "${USERNAME} false true /home/${USERNAME}/linuxbrew"
    runScript java "13.0.2.j9-adpt /usr/local/sdkman2 ${USERNAME} false"
    runScript kubectl-helm "latest latest latest"
    runScript maven "3.6.3 /usr/local/sdkman3 ${USERNAME} false" 
    runScript node "/usr/local/share/nvm 10 ${USERNAME}"
    runScript powershell
    runScript python "3.4.10 /opt/python ${USERNAME} false false"
    runScript ruby "${USERNAME} false" "2.5.8"
    runScript rust "/opt/rust/cargo /opt/rust/rustup ${USERNAME} false"
    runScript terraform "0.12.16" "0.8.2"
    runScript sshd "2223 ${USERNAME} true random"
    runScript desktop-lite "${USERNAME} changeme false"
    runSciprt docker-in-docker "false ${USERNAME} false"
fi

if [ "${DISTRO}" != "alpine" ] && [ "${RUN_ONE}" != "docker-in-docker" ]; then
    rm -f /usr/local/share/docker-init.sh
    runScript docker "true /var/run/docker-host.sock /var/run/docker.sock ${USERNAME}"
fi

if [ "${DISTRO}" = "alpine" ]; then
    echo '#!/bin/bash\n"$@"' > /usr/local/share/docker-init.sh
    chown ${USERNAME} /usr/local/share/docker-init.sh
    chmod +x /usr/local/share/docker-init.sh
fi
