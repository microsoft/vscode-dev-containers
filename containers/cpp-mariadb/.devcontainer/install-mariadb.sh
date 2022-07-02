#!/bin/bash
set -e

OSURL=""
OSTAG=""

find_os_props() {
    . /etc/os-release
    case $ID in
        debian)
            case $VERSION_CODENAME in
                stretch)
                    OSTAG="1683458"
                    OSURL="debian-9-stretch-amd64"
                    ;;
                *)
                    OSTAG="1683461"
                    OSURL="debian-buster-amd64"
                    ;;
            esac
            ;;
        ubuntu)
            case $VERSION_CODENAME in
                bionic)
                    OSTAG="1683439"
                    OSURL="ubuntu-bionic-amd64"
                    ;;
                groovy)
                    OSTAG="1683454"
                    OSURL="ubuntu-groovy-amd64"
                    ;;
                *)
                    OSTAG="1683444"
                    OSURL="ubuntu-focal-amd64"
                    ;;
            esac
            ;;
        *)
            echo "Unsupported OS choice."
            exit 1
            ;;
    esac
}

# Run apt-get if needed.
apt_get_update_if_needed() {
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

# Check if packages are installed and installs them if not.
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get -y install --no-install-recommends "$@"
    fi
}

TMP_DIR=$(mktemp -d -t maria-XXXXXXXXXX)
MARIADB_CONNECTOR=""
SOURCE_INCLUDE_DIR=""
SOURCE_LIB_DIR=""
SOURCE_PLUGIN_DIR=""

cleanup() {
    EXIT_CODE=$?
    set +e
    if [[ -n ${TMP_DIR} ]]; then
        cd /
        rm -rf ${TMP_DIR}
    fi
    exit $EXIT_CODE
}
trap cleanup EXIT

#Set up external repository and install C Connector
check_packages libmariadb3 libmariadb-dev

#Depending on the OS, install different C++ connectors
find_os_props

cd ${TMP_DIR}

if [ "$(dpkg --print-architecture)" = "arm64" ] ; then
    # Instructions are copied and modified from: https://github.com/mariadb-corporation/mariadb-connector-cpp/blob/master/BUILD.md
    # and from: https://mariadb.com/docs/clients/mariadb-connectors/connector-cpp/install/
    check_packages git cmake make gcc libssl-dev
    git clone https://github.com/MariaDB-Corporation/mariadb-connector-cpp.git
    mkdir build && cd build
    cmake ../mariadb-connector-cpp/ -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCONC_WITH_UNIT_TESTS=Off -DCMAKE_INSTALL_PREFIX=/usr/local -DWITH_SSL=OPENSSL
    cmake --build . --config RelWithDebInfo
    make install

    SOURCE_INCLUDE_DIR="../mariadb-connector-cpp/include"
    SOURCE_LIB_DIR="."
    SOURCE_PLUGIN_DIR="./libmariadb"
else
    # Instructions are copied and modified from: https://mariadb.com/docs/clients/mariadb-connectors/connector-cpp/install/
    MARIADB_CONNECTOR=mariadb-connector-cpp-1.0.1-$OSURL
    curl -Ls https://dlm.mariadb.com/$OSTAG/connectors/cpp/connector-cpp-1.0.1/${MARIADB_CONNECTOR}.tar.gz -o ${MARIADB_CONNECTOR}.tar.gz
    tar -xvzf ${MARIADB_CONNECTOR}.tar.gz && cd ${MARIADB_CONNECTOR}

    SOURCE_INCLUDE_DIR="./include/mariadb"
    SOURCE_LIB_DIR="lib/mariadb"
    SOURCE_PLUGIN_DIR="lib/mariadb/plugin"
fi 

install -d /usr/include/mariadb/conncpp/compat
install -d /usr/lib/mariadb/plugin

#Header Files being copied into the necessary directories
cp -R ${SOURCE_INCLUDE_DIR}/* /usr/include/mariadb/
cp -R ${SOURCE_INCLUDE_DIR}/conncpp/* /usr/include/mariadb/conncpp
cp -R ${SOURCE_INCLUDE_DIR}/conncpp/compat/* /usr/include/mariadb/conncpp/compat

#Shared libraries copied into usr/lib
cp ${SOURCE_LIB_DIR}/libmariadbcpp.so /usr/lib
cp ${SOURCE_PLUGIN_DIR}/*.so /usr/lib/mariadb/plugin    
