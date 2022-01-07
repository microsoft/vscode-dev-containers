#!/bin/sh

. /etc/os-release

#Set up external repository and install C Connector
curl -O -L https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
echo "5feb2aac767c512cc9e2af674d1aef42df0b775ba2968fffa8700eb42702bd44  mariadb_es_repo_setup" | sha256sum -c - 
chmod +x mariadb_repo_setup
./mariadb_repo_setup --mariadb-server-version="mariadb-10.6"
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
curl -O -L https://dlm.mariadb.com/$OSTAG/connectors/cpp/connector-cpp-1.0.1/mariadb-connector-cpp-1.0.1-$OSURL.tar.gz
tar -xvzf mariadb-connector-cpp-1.0.1-$OSURL.tar.gz

ls

cd mariadb-connector-cpp-1.0.1-$OSURL
install -d /usr/include/mariadb/conncpp

#Header Files being copied into the necessary directories
cp -R ./include/mariadb/* /usr/include/mariadb/
cp -R ./include/mariadb/conncpp/* /usr/include/mariadb/conncpp
cp -R include/mariadb/conncpp/compat/* /usr/include/mariadb/conncpp/compat

install -d /usr/lib/mariadb
install -d /usr/lib/mariadb/plugin

#Shared libraries copied into usr/lib
cp lib/mariadb/libmariadbcpp.so /usr/lib
cp -R lib/mariadb/plugin/* /usr/lib/mariadb/plugin