#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Actual tests
checkExtension "felixfbecker.php-debug"
checkExtension "felixfbecker.php-intellisense"
checkExtension "mrmlnc.vscode-apache"
checkExtension "mtxr.sqltools"
checkExtension "mtxr.sqltools-driver-mysql"
check "php" php --version
sleep 15 # Sleep to be sure MariaDB is running.
check "mariadb" mariadb -h localhost -P 3306 --protocol=tcp -u root --password=mariadb -D mariadb -Bse exit

# Report result
reportResults
