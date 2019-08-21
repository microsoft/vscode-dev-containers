#!/usr/bin/env bash
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
    checkMultiple "$1" 1 "[ -d ""$HOME/.vscode-server/extensions/$1*"" ]" "[ -d ""$HOME/.vscode-server-insiders/extensions/$1*"" ]" "[ -d ""$HOME/.vscode-test-server/extensions/$1*"" ]"
}

# Prep
echo -e "\nGetting Maven wrapper..."
curl -sSL https://github.com/takari/maven-wrapper/archive/maven-wrapper-0.5.5.tar.gz| tar -xzf -
mv maven-wrapper-maven-wrapper-0.5.5/mvnw mvnw
mv maven-wrapper-maven-wrapper-0.5.5/.mvn .mvn
rm -rf mv maven-wrapper-maven-wrapper-0.5.5

# Actual tests
checkMultiple "vscode-server" 1 "[ -d ""$HOME/.vscode-server/bin"" ]" "[ -d ""$HOME/.vscode-server-insiders/bin"" ]" "[ -d ""$HOME/.vscode-test-server/bin"" ]"
checkExtension "vscjava.vscode-java-pack"
check "non-root-user" "id vscode"
check "/home/vscode" [ -d "/home/vscode" ]
check "sudo" sudo -u vscode echo "sudo works."
check "git" git --version
check "command-line-tools" which top ip lsb_release curl
check "java" java -version
check "build-and-test-jar" ./mvnw package
check "test-project" java -jar target/my-app-1.0-SNAPSHOT.jar

# Clean up
rm -f mvnw
rm -rf .mvn

# Report result
if [ ${#FAILED[@]} -ne 0 ]; then
    echo -e "\n💥  Failed tests: ${FAILED[@]}"
    exit 1
else 
    echo -e "\n💯  All passed!"
    exit 0
fi
