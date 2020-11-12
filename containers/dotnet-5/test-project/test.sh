#!/bin/bash -i
cd $(dirname "$0")

if [ -z $HOME ]; then
    HOME="/root"
fi

FAILED=()

check() {
    LABEL=$1
    shift
    echo -e "\n🧪  Testing $LABEL: $@"
    if $@; then 
        echo "🏆  Passed!"
    else
        echo "💥  $LABEL check failed."
        FAILED+=("$LABEL")
    fi
}

checkMultiple() {
    PASSED=0
    LABEL="$1"
    shift; MINIMUMPASSED=$1
    shift; EXPRESSION="$1"
    while [ "$EXPRESSION" != "" ]; do
        if $EXPRESSION; then ((PASSED++)); fi
        shift; EXPRESSION=$1
    done
    check "$LABEL" [ $PASSED -ge $MINIMUMPASSED ]
}

checkExtension() {
    checkMultiple "$1" 1 "[ -d ""$HOME/.vscode-server/extensions/$1*"" ]" "[ -d ""$HOME/.vscode-server-insiders/extensions/$1*"" ]" "[ -d ""$HOME/.vscode-test-server/extensions/$1*"" ]" "[ -d ""$HOME/.vscode-remote/extensions/$1*"" ]"
}

# Execute .bashrc with the SYNC_LOCALHOST_KUBECONFIG set
export SYNC_LOCALHOST_KUBECONFIG=true 

# Run Docker init script
/usr/local/share/docker-init.sh

# Actual tests
checkMultiple "vscode-server" 1 "[ -d ""$HOME/.vscode-server/bin"" ]" "[ -d ""$HOME/.vscode-server-insiders/bin"" ]" "[ -d ""$HOME/.vscode-test-server/bin"" ]" "[ -d ""$HOME/.vscode-remote/bin"" ]"
check "non-root-user" "id vscode"
check "/home/vscode" [ -d "/home/vscode" ]
check "sudo" sudo echo "sudo works."
check "git" git --version
check "command-line-tools" which top ip lsb_release wget curl jq less nano unzip
check "zsh" zsh --version
check "oh-my-zsh" [ -d "$HOME/.oh-my-zsh" ]
# user tests
check "non-root-user" "id vscode"
check "/home/vscode" [ -d "/home/vscode" ]
# docker and kubernetes tests
checkExtension "ms-azuretools.vscode-docker"
checkExtension "ms-kubernetes-tools.vscode-kubernetes-tools"
check "docker" sudo docker ps -a
check "docker-compose" docker-compose --version
check "docker-socket" ls -l /var/run/docker.sock 
check "kube-config-mount" ls -l /usr/local/share/kube-localhost
check "kube-config" ls -l "$HOME/.kube"
check "kubectl" kubectl version --client
check "helm" helm version --client
# Azure CLI tests
checkExtension "ms-vscode.azurecli"
check "azure-cli" az --version
# Github CLI 
check "github-cli" gh --version
# Powershell tests
checkExtension "ms-vscode.powershell"
check "powershell" pwsh hello.ps1
# Go Tests
checkExtension "golang.Go"
check "go" go version
# NodeJS tests
checkExtension "dbaeumer.vscode-eslint"
check "node" node --version
check "nvm" nvm --version
check "yarn" yarn install --cd-datadir ./nodejs
check "npm" "bash -c cd nodejs && npm install"
check "eslint" "eslint nodejs/server.js"
check "test-project/nodejs" "bash -c cd nodejs && npm run test"
# TypeScript tests
checkExtension "ms-vscode.vscode-typescript-tslint-plugin"
check "yarn" yarn install --cd-datadir ./typescript
check "npm" "bash -c cd typescript && npm install"
check "tslint" "tslint typescript/src/server.ts"
check "eslint" "eslint --no-eslintrc -c typescript/.eslintrc.json typescript/src/server.ts"
check "typescript" "bash -c cd typescript && npm run compile"
check "test-project/typescript" "bash -c cd typescript && npm run test"


# Report result
if [ ${#FAILED[@]} -ne 0 ]; then
    echo -e "\n💥  Failed tests: ${FAILED[@]}"
    exit 1
else 
    echo -e "\n💯  All passed!"
    exit 0
fi
