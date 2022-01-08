#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Run common tests
checkCommon

# Definition specific tests
checkExtension "vadimcn.vscode-lldb"
checkExtension "mutantdino.resourcemonitor"
checkExtension "matklad.rust-analyzer"
checkExtension "tamasfe.even-better-toml"
checkExtension "serayuzgur.crates"
checkExtension "mtxr.sqltools"
checkExtension "mtxr.sqltools-driver-pg"
check "cargo" cargo -V
check "build-and-run" cargo run

# Clean up
rm -f Cargo.lock

# Report result
reportResults