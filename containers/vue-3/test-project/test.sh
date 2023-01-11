#!/bin/bash
cd $(dirname "$0")

source test-utils.sh node

# Run common tests
checkCommon

# Run definition specific tests

checkExtension octref.vetur
checkExtension dbaeumer.vscode-eslint
checkExtension esbenp.prettier-vscode
checkExtension streetsidesoftware.code-spell-checker
checkExtension visualstudioexptteam.vscodeintellicode
checkExtension msjsdiag.debugger-for-chrome
checkExtension firefox-devtools.vscode-firefox-debug
SPECIFIC_PACKAGE_LIST="fzf \
        silversearcher-ag"
checkOSPackages "specific-os-packages" ${SPECIFIC_PACKAGE_LIST}

# Report result
reportResults
