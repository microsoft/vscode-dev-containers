#!/bin/bash
SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

cd "${SCRIPT_DIR}"
rm -rf out
mkdir -p out
cp src/* ../*.sh out/