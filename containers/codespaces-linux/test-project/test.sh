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

# Actual tests
USERNAME=codespace
if ! ./test-common.sh ${USERNAME}; then
    FAILED+=("common-tests")
fi

# Check Oryx
check "oryx" oryx platforms

# Check .NET
check "dotnet" dotnet --info

# Check Python
check "python" python --version
check "pip" pip3 --version
check "pipx" pipx --version
check "pylint" pylint --version
check "flake8" flake8 --version
check "autopep8" autopep8 --version
check "yapf" yapf --version
check "mypy" mypy --version
check "pydocstyle" pydocstyle --version
check "bandit" bandit --version
check "virtualenv" virtualenv --version

# Check Java tools
check "java" java -version
check "sdkman" sdk --version
check "gradle" gradle --version
check "maven" mvn --version

# Check Ruby tools
check "ruby" ruby --version
check "rvm" rvm --version
check "rake" rake --version

# Node.js
check "node" node --version
check "nvm" nvm --version
check "nvs" nvs --version
check "yarn" yarn --version
check "npm" npm --version

# PHP
check "php" php --version

# Rust
check "cargo" cargo --version
check "rustup" rustup --version
check "rls" rls --version
check "rustfmt" rustfmt --version
check "clippy" cargo-clippy --version
check "lldb" which lldb

# Check utilities
checkOSPackages "additional-os-packages" vim xtail software-properties-common
check "az" az --version
check "gh" gh --version
check "git-lfs" git-lfs --version
check "docker" docker --version
check "kubectl" kubectl version --client
check "helm" helm version

# Check expected shells
check "bash" bash --version
check "fish" fish --version
check "zsh" zsh --version

# Check expected commands
check "git-ed" test "$(cat $(which git-ed.sh))" = "$(cat ./git-ed-expected.txt)"

# -- Report results --
if [ ${#FAILED[@]} -ne 0 ]; then
    echo -e "\n💥  Failed tests: ${FAILED[@]}"
    exit 1
else 
    echo -e "\n💯  All passed!"
    exit 0
fi
