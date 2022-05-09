#!/usr/bin/env bash

set -e

PYTHON=${1:-"python"}
USERNAME=${2-"automatic"}

# Make sure we run the command as non-root user
sudoUserIf() {
  if [ "$(id -u)" -eq 0 ] && [ "${USERNAME}" != "root" ]; then
    sudo -u ${USERNAME} "$@"
  else
    "$@"
  fi
}

installPythonPackage() {
  PACKAGE=${1:-""}
  VERSION=${2:-"latest"}

  # pip skips installation if the package is already installed
  echo "Installing $PACKAGE..."
  if [ "${VERSION}" = "latest" ]; then
    sudoUserIf ${PYTHON} -m pip install ${PACKAGE} --no-cache-dir
  else
    sudoUserIf ${PYTHON} -m pip install ${PACKAGE}=="${VERSION}" --no-cache-dir
  fi
}

# If in automatic mode, determine if a user already exists, if not use vscode
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in ${POSSIBLE_USERS[@]}; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=vscode
    fi
elif [ "${USERNAME}" = "none" ]; then
    USERNAME=root
    USER_UID=0
    USER_GID=0
fi

# Make sure that Python is available
if ! ${PYTHON} --version > /dev/null ; then
  echo "You need to install Python before installing packages"
  exit 1
fi

installPythonPackage "numpy" "latest"
installPythonPackage "pandas" "latest"
installPythonPackage "scipy" "latest"
installPythonPackage "matplotlib" "latest"
installPythonPackage "seaborn" "latest"
installPythonPackage "scikit-learn" "latest"
installPythonPackage "tensorflow" "latest"
installPythonPackage "keras" "latest"
installPythonPackage "torch" "latest"
installPythonPackage "requests" "latest"
