#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Actual tests
checkExtension "ms-azuretools.vscode-docker"
checkExtension "ms-kubernetes-tools.vscode-kubernetes-tools"
check "docker" docker ps -a
check "kubectl" kubectl version --client=true --output=yaml
check "helm" helm version --client
check "k3d start" k3d cluster start
check "k3d stop" k3d cluster stop
check "k3d delete" k3d cluster delete
docker image prune -a -f

# Report result
reportResults

