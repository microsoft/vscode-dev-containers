#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Run definition specific tests
checkExtension "ms-vscode.cpptools"
checkOSPackages "command-line-tools" build-essential cmake cppcheck valgrind clang lldb llvm gdb
check "g++"  g++ -g main.cpp -o main.out
rm main.out
mkdir -p build
cd build
check "cmake" cmake ..
cd ..
rm -rf build

## Report result
reportResults
