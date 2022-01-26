#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Remote - Containers does not auto-sync UID/GID for Docker Compose,
# so make sure test project prvs match the non-root user in the container.
fixTestProjectFolderPrivs

# Run common tests
checkCommon

# Actual tests
checkExtension "felixfbecker.php-debug"
checkExtension "felixfbecker.php-intellisense"
checkExtension "mrmlnc.vscode-apache"
check "php" php --version
check "apache2ctl" which apache2ctl
sleep 15 # Sleep to be sure MariaDB is running.
check "mariadb" mariadb -h localhost -P 3306 --protocol=tcp -u root --password=mariadb -D mariadb -Bse exit

# Report result
reportResults
