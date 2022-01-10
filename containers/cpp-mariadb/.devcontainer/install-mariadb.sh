#!/bin/bash
set -e

. /etc/os-release

MARIADB_REPO_SETUP=mariadb_repo_setup
TMP_DIR=$(mktemp -d -t maria-XXXXXXXXXX)
MARIADB_CONNECTOR=""

function cleanup {
    cd /
    rm -rf ${TMP_DIR}/${MARIADB_REPO_SETUP}
    rm -rf ${TMP_DIR}/${MARIADB_CONNECTOR}*
}
trap cleanup EXIT

#Set up external repository and install C Connector
cd ${TMP_DIR}
curl -Ls https://downloads.mariadb.com/MariaDB/${MARIADB_REPO_SETUP} -o ${MARIADB_REPO_SETUP}
echo "fd3f41eefff54ce144c932100f9e0f9b1d181e0edd86a6f6b8f2a0212100c32c  ${MARIADB_REPO_SETUP}" | sha256sum -c -
chmod +x ${MARIADB_REPO_SETUP}
./${MARIADB_REPO_SETUP} --mariadb-server-version="mariadb-10.6"
apt install -y libmariadb3 libmariadb-dev

#Depending on the OS, install different C++ connectors
OSURL=""
OSTAG=""
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
        exit 0
        ;;
esac

# Instructions are copied and modified from: https://mariadb.com/docs/clients/mariadb-connectors/connector-cpp/install/
MARIADB_CONNECTOR=mariadb-connector-cpp-1.0.1-$OSURL
curl -Ls https://dlm.mariadb.com/$OSTAG/connectors/cpp/connector-cpp-1.0.1/${MARIADB_CONNECTOR}.tar.gz -o ${MARIADB_CONNECTOR}.tar.gz
tar -xvzf ${MARIADB_CONNECTOR}.tar.gz && cd ${MARIADB_CONNECTOR}
install -d /usr/include/mariadb/conncpp

#Header Files being copied into the necessary directories
cp -R ./include/mariadb/* /usr/include/mariadb/
cp -R ./include/mariadb/conncpp/* /usr/include/mariadb/conncpp
cp -R ./include/mariadb/conncpp/compat/* /usr/include/mariadb/conncpp/compat

install -d /usr/lib/mariadb
install -d /usr/lib/mariadb/plugin

#Shared libraries copied into usr/lib
cp lib/mariadb/libmariadbcpp.so /usr/lib
cp -R lib/mariadb/plugin/* /usr/lib/mariadb/plugin
