#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Execute .bashrc with the SYNC_LOCALHOST_KUBECONFIG set
export SYNC_LOCALHOST_KUBECONFIG=true 
exec bash

# Actual tests
checkExtension "ms-azuretools.vscode-docker"
checkExtension "ms-kubernetes-tools.vscode-kubernetes-tools"
check "docker-socket" ls -l /var/run/docker.sock 
check "docker" docker ps -a
check "kube-config-mount" ls -l /usr/local/share/kube-localhost
check "kube-config" ls -l "$HOME/.kube"
check "kubectl" kubectl version --client
check "helm" helm version --client

# Report result
reportResults

