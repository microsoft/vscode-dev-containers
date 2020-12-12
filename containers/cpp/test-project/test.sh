#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Run definition specific tests
checkExtension "ms-vscode.cpptools"
check "command-line-tools" g++ gcc cmake cppcheck valgrind 
check "g++"  g++ -g main.cpp -o main.out
rm main.out
mkdir -p build
cd build
check "cmake" cmake ..
cd ..
rm -rf build

## Report result
reportResults
