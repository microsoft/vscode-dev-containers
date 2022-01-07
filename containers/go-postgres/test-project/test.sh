#!/bin/bash
cd $(dirname "$0")

source test-utils.sh

# Run common tests
checkCommon

# Run definition specific tests
checkExtension "golang.Go"
checkExtension "mtxr.sqltools"
checkExtension "mtxr.sqltools-driver-pg"

check "lib pq check" go list github.com/lib/pq
check "go test program" go run hello.go

## Report result
reportResults
