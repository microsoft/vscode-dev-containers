#!/usr/bin/env bash
set -e
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verify we're on a supported OS
. /etc/os-release
if [ "${ID}" != "debian" ] &&  [ "${ID_LIKE}" != "debian" ]; then
cat << EOF

*********** Unsupported operating system "${ID}" detected ***********

Features support currently requires a Debian/Ubuntu-based image. Update your 
image or Dockerfile FROM statement to start with a supported OS. For example:
mcr.microsoft.com/vscode/devcontainers/base:ubuntu

Aborting build...

EOF
    exit 2
fi

set -a
. ./devcontainer-features.env
set +a

chmod +x *.sh

# Execute option scripts if correct environment variable is set to "true"
feature_marker_path="/usr/local/etc/vscode-dev-containers/features"
mkdir -p "${feature_marker_path}"
while IFS= read -r feature_line; do
    # Extract the env var part of the line
    feature_var_name="${feature_line%%=*}"
    if [ ! -z "${!feature_var_name}" ]; then
        # If a value is set for the env var, execute the script
        feature_script_and_args="${feature_line##*=}"
        feature_script_and_args="${feature_script_and_args%\"}"
        script_command="$(eval echo "${feature_script_and_args#\"}")"
        echo "(*) Script: ${script_command}"

        # Check if script with same args has already been run
        feature_marker="${feature_marker_path}/${feature_var_name}";
        if [ -e "${feature_marker}" ] && [ "${script_command}" = "$(cat ${feature_marker})" ]; then
            echo "(*) Skipping. Script already run with same arguments."
        else
            # Execute script and create a marker with the script args
            ./${script_command}
            echo "${script_command}" > "${feature_marker}"
        fi
    fi
done < ./feature-scripts.env

# Clean up
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
