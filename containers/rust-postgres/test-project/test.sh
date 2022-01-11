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
check "cargo-version" cargo -V
check "cargo-run" cargo run
check "cargo-integration-test" cargo test --test '*' -- --nocapture

# Report result
reportResults
