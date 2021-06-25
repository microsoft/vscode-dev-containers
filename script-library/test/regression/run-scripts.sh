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
    if [ "${RUN_ONE}" != "false" ] && [ "${SCRIPT_NAME}" != "common" ] && [ "${SCRIPT_NAME}" != "${RUN_ONE}" ]; then
        return
    fi
    if [ "${SCRIPT_NAME}" = "docker" ] || [ "${SCRIPT_NAME}" = "docker-in-docker" ]; then
        rm -f /usr/local/share/docker-init.sh
    fi
    if [ "${SCRIPT_NAME}" = "sshd" ]; then
        rm -f /usr/local/share/ssh-init.sh
    fi
    if [ "${SCRIPT_NAME}" = "desktop-lite" ]; then
        rm -f /usr/local/share/desktop-init.sh
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

echo '#!/bin/bash\n"$@"' | tee /usr/local/share/docker-init.sh /usr/local/share/ssh-init.sh > /usr/local/share/desktop-init.sh
chmod +x /usr/local/share/docker-init.sh /usr/local/share/ssh-init.sh /usr/local/share/desktop-init.sh
if [ "${RUN_COMMON_SCRIPT}" = "true" ]; then
    runScript common "true ${USERNAME} 1000 1000 ${UPGRADE_PACKAGES}"
    chown 1000 /usr/local/share/docker-init.sh /usr/local/share/ssh-init.sh /usr/local/share/desktop-init.sh
fi

ARCHITECTURE="$(uname -m)"
if [ "${DISTRO}" = "debian" ]; then
    runScript azcli
    runScript fish "false ${USERNAME}"
    runScript git-from-src "2.26.2"
    runScript git-lfs
    runScript github
    runScript go "1.14 /opt/go /go ${USERNAME} false"
    runScript gradle "4.4 /usr/local/sdkman1 ${USERNAME} false"
    runScript kubectl-helm "latest latest latest"
    runScript maven "3.6.3 /usr/local/sdkman3 ${USERNAME} false" 
    runScript node "/usr/local/share/nvm 10 ${USERNAME}"
    runScript python "3.4.10 /opt/python ${USERNAME} false false"
    runScript ruby "${USERNAME} false" "2.5.8"
    runScript rust "/opt/rust/cargo /opt/rust/rustup ${USERNAME} false"
    runScript terraform "0.8.2 0.12.16"
    runScript sshd "2223 ${USERNAME} true random"
    runScript desktop-lite "${USERNAME} changeme false"
    runScript docker-in-docker "false ${USERNAME} false"
    if [ "${ARCHITECTURE}" = "amd4" ] || [ "${ARCHITECTURE}" = "x86_64" ] || [ "${ARCHITECTURE}" = "arm64" ] || [ "${ARCHITECTURE}" = "aarch64" ]; then
        runScript java "13.0.2.j9-adpt /usr/local/sdkman2 ${USERNAME} false"
    fi
    if [ "${ARCHITECTURE}" = "amd64" ] || [ "${ARCHITECTURE}" = "x86_64" ]; then
        runScript powershell
        runScript homebrew "${USERNAME} false true /home/${USERNAME}/linuxbrew"
    fi 
fi

if [ "${DISTRO}" != "alpine" ]; then
    runScript docker "true /var/run/docker-host.sock /var/run/docker.sock ${USERNAME}"
fi
