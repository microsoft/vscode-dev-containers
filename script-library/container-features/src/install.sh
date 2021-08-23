#!/usr/bin/env bash
set -e

set -a
. /tmp/library-scripts/features.env
set +a

chmod +x /tmp/library-scripts/*.sh

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
        eval "/tmp/library-scripts/${feature_script_and_args#\"}"
    fi
done < /tmp/library-scripts/feature-scripts.env

# Clean up
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
