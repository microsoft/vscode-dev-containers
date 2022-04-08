#!/bin/bash

SCRIPT_DIR=${1-"/tmp"}
USE_DEFAULTS=${2:-"true"}
USERNAME=${3:-"vscode"}
RUN_COMMON_SCRIPT=${4:-"true"}
UPGRADE_PACKAGES=${5:-"true"}
RUN_ONE=${6:-"false"} # false or script name

set -e

runScript()
{
    local script_name=$1
    if [ "${RUN_ONE}" != "false" ] && [ "${script_name}" != "common" ] && [ "${script_name}" != "${RUN_ONE}" ]; then
        return
    fi
    if [ "${script_name}" = "docker" ] || [ "${script_name}" = "docker-in-docker" ]; then
        rm -f /usr/local/share/docker-init.sh
    fi
    if [ "${script_name}" = "sshd" ]; then
        rm -f /usr/local/share/ssh-init.sh
    fi
    if [ "${script_name}" = "desktop-lite" ]; then
        rm -f /usr/local/share/desktop-init.sh
    fi
    local script="${SCRIPT_DIR}/${script_name}-${DISTRO}.sh"
    chmod +x "${script}"
    local optional_args="$2"
    local required_prefix_args="${3:-""}"
    echo "**** Testing $script ****"
    if [ "${USE_DEFAULTS}" = "true" ]; then
        echo "Using defaults..."
        ${script} ${required_prefix_args}
    else
        echo "Arguments: ${required_prefix_args} ${optional_args}"
        ${script} ${required_prefix_args} ${optional_args}
    fi
    echo "**** Done! ****"
}

# Determine distro scripts to use
. /etc/os-release
DISTRO="${ID_LIKE}"
if [ -z "${DISTRO}" ]; then
    DISTRO="${ID}"
fi
if [[ "${DISTRO}" = *"rhel"* ]] ||[[ "${DISTRO}" = *"centos"* ]] || [[ "${DISTRO}" = *"fedora"* ]]; then
    DISTRO="redhat"
fi

cat << EOF
- SCRIPT_DIR=${SCRIPT_DIR}
- DISTRO=${DISTRO}
- USE_DEFAULTS=${USE_DEFAULTS}
- USERNAME=${USERNAME}
- RUN_COMMON_SCRIPT=${RUN_COMMON_SCRIPT}
- UPGRADE_PACKAGES=${UPGRADE_PACKAGES}
- RUN_ONE=${RUN_ONE}

EOF

tee /usr/local/share/docker-init.sh /usr/local/share/ssh-init.sh > /usr/local/share/desktop-init.sh << 'EOF'
#!/bin/bash
"$@"
EOF
chmod +x /usr/local/share/docker-init.sh /usr/local/share/ssh-init.sh /usr/local/share/desktop-init.sh
if [ "${RUN_COMMON_SCRIPT}" = "true" ]; then
    runScript common "true ${USERNAME} 1000 1000 ${UPGRADE_PACKAGES}"
    chown 1000 /usr/local/share/docker-init.sh /usr/local/share/ssh-init.sh /usr/local/share/desktop-init.sh
fi

architecture="$(uname -m)"
if [ "${DISTRO}" = "debian" ]; then
    runScript awscli
    runScript azcli
    runScript fish "false ${USERNAME}"
    runScript git-from-src "latest true"
    runScript git-lfs "" "2.13.3"
    runScript github
    runScript go "1.14 /opt/go /go ${USERNAME} false"
    runScript gradle "4.4 /usr/local/sdkman1 ${USERNAME} false"
    runScript kubectl-helm "latest latest latest"
    runScript maven "3.6.3 /usr/local/sdkman3 ${USERNAME} false"
    runScript node "/usr/local/share/nvm 10 ${USERNAME}"
    runScript python "3.4.10 /opt/python /opt/python-tools ${USERNAME} false false"
    runScript ruby "${USERNAME} false" "2.7.3"
    runScript rust "/opt/rust/cargo /opt/rust/rustup ${USERNAME} false"
    runScript terraform "0.15.0 0.12.1"
    runScript sshd "2223 ${USERNAME} true random"
    runScript desktop-lite "${USERNAME} changeme false"
    runScript docker-in-docker "false ${USERNAME} false 20.10 v2"
    runScript powershell
    runScript fish
    if [ "${architecture}" = "amd64" ] || [ "${architecture}" = "x86_64" ] || [ "${architecture}" = "arm64" ] || [ "${architecture}" = "aarch64" ]; then
        runScript java "13.0.2.j9-adpt /usr/local/sdkman2 ${USERNAME} false"
    fi
    if [ "${architecture}" = "amd64" ] || [ "${architecture}" = "x86_64" ]; then
        runScript homebrew "${USERNAME} false true /home/${USERNAME}/linuxbrew"
    fi
    runScript dotnet "3.1 true ${USERNAME} false /opt/dotnet dotnet"
fi

if [ "${DISTRO}" != "alpine" ]; then
    runScript docker "true /var/run/docker-host.sock /var/run/docker.sock ${USERNAME}"
fi
