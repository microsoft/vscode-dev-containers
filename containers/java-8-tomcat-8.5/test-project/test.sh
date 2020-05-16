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

# Actual tests
checkMultiple "vscode-server" 1 "[ -d ""$HOME/.vscode-server/bin"" ]" "[ -d ""$HOME/.vscode-server-insiders/bin"" ]" "[ -d ""$HOME/.vscode-test-server/bin"" ]"
checkExtension "vscjava.vscode-java-pack"
check "non-root-user" "id vscode"
check "/home/vscode" [ -d "/home/vscode" ]
check "sudo" sudo echo "sudo works."
check "git" git --version
check "command-line-tools" which top ip lsb_release curl
check "java" java -version
check "build-and-test-jar" mvn package
sudo mv target/mywebapp-0.0.1-SNAPSHOT.war $CATALINA_HOME/webapps/mywebapp.war
sudo touch $CATALINA_HOME/logs/catalina.out
check "tomcat-startup" sudo $CATALINA_HOME/bin/startup.sh
STARTED=0
while [ "$STARTED" == "0" ]; do
    echo "Waiting for deployment to be done..."
    STARTED=$(cat $CATALINA_HOME/logs/catalina.out | grep "c.m.mywebapp.MywebappApplication         : Started MywebappApplication" | wc -l)
    sleep 2
done
check "test-project" [ "$(curl -o /dev/null -sSLI -w '%{http_code}\n' 'http://localhost:8080/mywebapp')" == "200" ]
check "tomcat-shutdown" sudo $CATALINA_HOME/bin/shutdown.sh

# Cleanup
sudo rm $CATALINA_HOME/webapps/mywebapp.war
sudo rm -rf $CATALINA_HOME/webapps/mywebapp

# Report result
if [ ${#FAILED[@]} -ne 0 ]; then
    echo -e "\n💥  Failed tests: ${FAILED[@]}"
    exit 1
else 
    echo -e "\n💯  All passed!"
    exit 0
fi
