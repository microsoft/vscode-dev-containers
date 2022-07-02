#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Help determine distro
. /etc/os-release 

# Run definition specific tests
checkExtension "ms-vscode.cpptools"
checkExtension "ms-vscode.cmake-tools"
checkExtension "ms-vscode.cpptools-extension-pack"
checkOSPackages "command-line-tools" build-essential cmake cppcheck valgrind clang lldb llvm gdb
checkOSPackages "tools-for-vcpkg" tar curl zip unzip pkg-config bash-completion ninja-build
VCPKG_UNSUPPORTED_ARM64_VERSION_CODENAMES="stretch bionic"
if [ "$(dpkg --print-architecture)" = "amd64" ] || [[ ! "${VCPKG_UNSUPPORTED_ARM64_VERSION_CODENAMES}" = *"${VERSION_CODENAME}"* ]]; then
    check "VCPKG_ROOT" [ -d "${VCPKG_ROOT}" ]
    check "VCPKG_DOWNLOAD" [ -d "${VCPKG_DOWNLOADS}" ]
    VCPKG_FORCE_SYSTEM_BINARIES=1 check "vcpkg-from-root" ${VCPKG_ROOT}/vcpkg --version
    VCPKG_FORCE_SYSTEM_BINARIES=1 check "vcpkg-from-bin" vcpkg --version
fi 
checkOSPackages "tools-for-mariadb" libmariadb3 libmariadb-dev
check "g++"  g++ -g main.cpp -o main.out -lmariadbcpp
# MariaDB may take a few seconds to start, so retry on failure
check_ok=false
retry_count=0
until [ "${check_ok}" = "true" ] || [ "${retry_count}" -eq "5" ]; do
    ./main.out && check_ok=true
    if [ "${check_ok}" != "true" ]; then
        echo "(*) Check failed, DB may not be up yet. Retrying in 5s..."
        (( retry_count++ ))
        sleep 5s
    fi
done
check "main.out" sh -c "[ \"${check_ok}\" = \"true\" ]"
rm main.out
mkdir -p build
cd build
check "cmake" cmake ..
cd ..
rm -rf build

## Report result
reportResults
