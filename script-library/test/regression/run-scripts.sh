#!/bin/bash

SCRIPT_DIR=${1-"/tmp"}
USE_DEFAULTS=${2:-"true"}
USERNAME=${3:-"vscode"}
RUN_COMMON_SCRIPT=${4:-"true"}
UPGRADE_PACKAGES=${5:-"true"}
RUN_ONE=${6:-"false"} # false or script name

set -e

# Test runner. If RUN_ONE is set, then the script will only execute when the script argument martches.
# This script will be fired twice. Once with "USE_DEFAULTS" true, once false to check both behaviors
# run_script <script name minus OS> [non-default test arguments] [arugments to always pass]
run_script()
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

get_common_setting() {
    # if [ "${common_settings_file_loaded}" != "true" ]; then
    #     curl -sfL "https://aka.ms/vscode-dev-containers/script-library/settings.env" 2>/dev/null -o /tmp/vsdc-settings.env || echo "Could not download settings file. Skipping."
    #     common_settings_file_loaded=true
    # fi
    cp  ${SCRIPT_DIR}/shared/settings.env  /tmp/vsdc-settings.env

    if [ -f "/tmp/vsdc-settings.env" ]; then
        local multi_line=""
        if [ "$2" = "true" ]; then multi_line="-z"; fi
        local result="$(grep ${multi_line} -oP "$1=\"?\K[^\"]+" /tmp/vsdc-settings.env | tr -d '\0')"
        if [ ! -z "${result}" ]; then declare -g $1="${result}"; fi
    fi
    echo "$1=${!1}"
}

# Determine distro scripts to use
. /etc/os-release
architecture="$(uname -m)"
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

# Add stub entrypoint scripts in the event RUN_ONE is set and not all of these would be executed
tee /usr/local/share/docker-init.sh /usr/local/share/ssh-init.sh > /usr/local/share/desktop-init.sh << 'EOF'
#!/bin/bash
"$@"
EOF
chmod +x /usr/local/share/docker-init.sh /usr/local/share/ssh-init.sh /usr/local/share/desktop-init.sh

# Run the common script unless disabled
if [ "${RUN_COMMON_SCRIPT}" = "true" ]; then
    run_script common "true ${USERNAME} 1000 1000 ${UPGRADE_PACKAGES}"
    chown 1000 /usr/local/share/docker-init.sh /usr/local/share/ssh-init.sh /usr/local/share/desktop-init.sh
fi

# Debian/Ubuntu specific tests
if [ "${DISTRO}" = "debian" ]; then

    # dotnet
    get_common_setting DOTNET_VERSION_CODENAMES_REQUIRE_OLDER_LIBSSL_1
    if [[ "${DOTNET_VERSION_CODENAMES_REQUIRE_OLDER_LIBSSL_1}" = *"${VERSION_CODENAME}"* ]]; then
        run_script dotnet "3.1 true ${USERNAME} false /opt/dotnet dotnet"

    else
        run_script dotnet "6.0 true ${USERNAME} false /opt/dotnet dotnet"
    fi

    run_script ruby "false" "3.1.2"
    run_script python "3.10 /opt/python /opt/python-tools ${USERNAME} false false"
    run_script awscli
    run_script azcli
    run_script fish "false ${USERNAME}"
    run_script git-from-src "latest true"
    run_script git-lfs "" "2.13.3"
    run_script github
    run_script go "1.17 /opt/go /go ${USERNAME} false"
    run_script gradle "4.4 /usr/local/sdkman1 ${USERNAME} false"
    run_script kubectl-helm "latest latest latest"
    run_script maven "3.6.3 /usr/local/sdkman3 ${USERNAME} false"
    run_script node "/usr/local/share/nvm 14 ${USERNAME}"
    run_script rust "/opt/rust/cargo /opt/rust/rustup ${USERNAME} false"
    run_script terraform "0.15.0 0.12.1"
    run_script sshd "2223 ${USERNAME} true random"
    run_script desktop-lite "${USERNAME} changeme false"

    # docker-in-docker
    get_common_setting DOCKER_MOBY_ARCHIVE_VERSION_CODENAMES
    if [[ "${DOCKER_MOBY_ARCHIVE_VERSION_CODENAMES}" != *"${VERSION_CODENAME}"* ]]; then
        # Do not use Moby
        echo 'testing moby: false'
        run_script docker-in-docker "false ${USERNAME} false latest v2"
    else
        # Use Moby
         echo 'testing moby: true'
        run_script docker-in-docker "false ${USERNAME} true latest v2"
    fi

    run_script powershell
    if [ "${architecture}" = "amd64" ] || [ "${architecture}" = "x86_64" ] || [ "${architecture}" = "arm64" ] || [ "${architecture}" = "aarch64" ]; then
        run_script java "13.0.2.j9-adpt /usr/local/sdkman2 ${USERNAME} false"
    fi
    if [ "${architecture}" = "amd64" ] || [ "${architecture}" = "x86_64" ]; then
        run_script homebrew "${USERNAME} false true /home/${USERNAME}/linuxbrew"
    fi
fi

# TODO: Most of this script does not execute since 'docker-in-docker' is run above
if [ "${DISTRO}" != "alpine" ]; then
    run_script docker "true /var/run/docker-host.sock /var/run/docker.sock ${USERNAME}"
fi
