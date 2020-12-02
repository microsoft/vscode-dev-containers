#!/bin/bash -i
cd $(dirname "$0")

USERNAME=$1

if [ -z $HOME ]; then
    HOME="/root"
fi

FAILED=()

check() {
    LABEL=$1
    shift
    echo -e "\n🧪  Testing $LABEL: $@"
    if "$@"; then 
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

checkOSPackages() {
    LABEL="$1"
    shift
    check "$LABEL" dpkg-query --show -f='${Package}: ${Version}\n' "$@"
}

checkExtension() {
    checkMultiple "$1" 1 "[ -d ""$HOME/.vscode-server/extensions/$1*"" ]" "[ -d ""$HOME/.vscode-server-insiders/extensions/$1*"" ]" "[ -d ""$HOME/.vscode-test-server/extensions/$1*"" ]" "[ -d ""$HOME/.vscode-remote/extensions/$1*"" ]"
}

# Settings
PACKAGE_LIST="apt-utils \
    git \
    openssh-client \
    less \
    iproute2 \
    procps \
    curl \
    wget \
    unzip \
    nano \
    jq \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    dialog \
    gnupg2 \
    libc6 \
    libgcc1 \
    libgssapi-krb5-2 \
    liblttng-ust0 \
    libstdc++6 \
    zlib1g \
    locales \
    sudo"

# Actual tests
checkOSPackages "common-os-packages" ${PACKAGE_LIST}
checkMultiple "vscode-server" 1 "[ -d ""$HOME/.vscode-server/bin"" ]" "[ -d ""$HOME/.vscode-server-insiders/bin"" ]" "[ -d ""$HOME/.vscode-test-server/bin"" ]" "[ -d ""$HOME/.vscode-remote/bin"" ]" "[ -d ""$HOME/.vscode-remote/bin"" ]"
check "non-root-user" id ${USERNAME}
check "/home/vscode" [ -d "/home/${USERNAME}" ]
check "locale" [ $(locale -a | grep en_US.utf8) ]
check "sudo" sudo echo "sudo works."
check "zsh" zsh --version
check "oh-my-zsh" [ -d "$HOME/.oh-my-zsh" ]
check "code" bash -i -c "code --version"

# Report result
if [ ${#FAILED[@]} -ne 0 ]; then
    echo -e "\n💥  Failed common tests: ${FAILED[@]}"
    exit 1
else 
    echo -e "\n💯  All common tests passed!"
    exit 0
fi
