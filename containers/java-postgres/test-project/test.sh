#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Prep
echo -e "\nGetting Maven wrapper..."
curl -sSL https://github.com/takari/maven-wrapper/archive/maven-wrapper-0.5.5.tar.gz| tar -xzf - 
mv maven-wrapper-maven-wrapper-0.5.5/mvnw mvnw
mv maven-wrapper-maven-wrapper-0.5.5/.mvn .mvn
rm -rf mv maven-wrapper-maven-wrapper-0.5.5

# Definition specific tests
checkExtension "vscjava.vscode-java-pack"
check "java" java -version
check "build-and-test-jar" ./mvnw -q package
check "test-project" java -jar target/my-app-1.0-SNAPSHOT.jar

# Clean up
rm -f mvnw
rm -rf .mvn

# Report result
reportResults
