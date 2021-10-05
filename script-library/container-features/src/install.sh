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
. ./features.env
set +a

chmod +x *.sh

# Execute option scripts if correct environment variable is set to "true"
while IFS= read -r feature_line; do
    # Extract the env var part of the line
    feature_var_name="${feature_line%%=*}"
    if [ ! -z "${!feature_var_name}" ]; then
        # If a value is set for the env var, execute the script
        feature_script_and_args="${feature_line##*=}"
        feature_script_and_args="${feature_script_and_args%\"}"
        # Execute the script line - but do not quote so arguments can be included in the 
        echo "${feature_script_and_args#\"}"
        eval "./${feature_script_and_args#\"}"
    fi
done < ./feature-scripts.env

# Clean up
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
