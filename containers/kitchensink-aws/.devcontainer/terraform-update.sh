#!/bin/bash

function terraform-update() {
  LATEST_TAG=$(curl --silent "https://api.github.com/repos/hashicorp/terraform/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
  LATEST_VER=$(echo $LATEST_TAG | grep -Po '[\d.]+')
  echo "Terraform latest release is ${LATEST_TAG}"
  if [[ -f /usr/local/bin/terraform ]]; then
    CURRENT_VERSION=$(/usr/local/bin/terraform version | grep -Po '[\d.]+')
    [[ ${LATEST_VER} == ${CURRENT_VERSION} ]] && echo "${LATEST_TAG} already installed at /usr/local/bin/terraform" && return 0
  fi
  LATEST_URL=https://releases.hashicorp.com/terraform/${LATEST_VER}/terraform_${LATEST_VER}_linux_amd64.zip
  curl -sSL -o /tmp/terraform.zip ${LATEST_URL}
  unzip /tmp/terraform.zip
  mv terraform /usr/local/bin
  rm /tmp/terraform.zip

  echo "Installed: `/usr/local/bin/terraform version`"
}

function tflint-update() {
  LATEST_TAG=$(curl --silent "https://api.github.com/repos/wata727/tflint/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
  LATEST_VER=$(echo $LATEST_TAG | grep -Po '[\d.]+')
  echo "TFLint Latest release is ${LATEST_TAG}"
  if [[ -f /usr/local/bin/tflint ]]; then
    CURRENT_VERSION=$(/usr/local/bin/tflint -v | grep -Po '[\d.]+')
    [[ ${LATEST_VER} == ${CURRENT_VERSION} ]] && echo "${LATEST_TAG} already installed at /usr/local/bin/tflint" && return 0
  fi
  LATEST_URL=https://github.com/wata727/tflint/releases/download/v${LATEST_VER}/tflint_linux_amd64.zip
  curl -sSL -o /tmp/tflint.zip ${LATEST_URL}
  unzip /tmp/tflint.zip
  mv tflint /usr/local/bin
  rm /tmp/tflint.zip

  echo "Installed: `/usr/local/bin/tflint -v`"
}

terraform-update
tflint-update