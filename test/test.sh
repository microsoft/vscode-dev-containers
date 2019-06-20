#!/usr/bin/env bash
#-------------------------------------------------------------
#  Copyright (c) Microsoft Corporation. All rights reserved.
#-------------------------------------------------------------

if [ "$1" = "help" ] || [ "$1" = "--help" ]; then
	echo "./test.sh [--trace] [background] [<definition/template/try> [definition ID/template name/try repo]]"
	exit 0
fi

BASEDIR=$(dirname "$0")
cd "$BASEDIR"

if [ ! -d node_modules ]; then
	yarn install
fi

if [ "$1" = "--trace" ]; then
	export TEST_LOG_LEVEL=trace
	shift
fi

if [ "$1" = "background" ]; then
	RUN_IN="background"
	shift
fi

TESTS="src/**/*.test.ts"
if [ "$1" = "definition" ] || [ "$1" = "definitions" ]; then
	TESTS="src/devContainerDefinitions.test.ts"
	export TEMPLATES_TO_TEST=none
	export DEFINITIONS_TO_TEST=$2
	export TRY_REPOS_TO_TEST=none
elif [ "$1" = "template" ] || [ "$1" = "templates" ]; then
	TESTS="src/devContainerTemplates.test.ts"
	export TEMPLATES_TO_TEST=$2
	export DEFINITIONS_TO_TEST=none
	export TRY_REPOS_TO_TEST=none
elif [ "$1" = "try" ]; then
	TESTS="src/tryRepositories.test.ts"
	export TEMPLATES_TO_TEST=none
	export DEFINITIONS_TO_TEST=none
	export TRY_REPOS_TO_TEST=$2
fi

export TS_NODE_IGNORE=false
if [ "$RUN_IN" = "background" ]; then 
	nohup npx mocha -r ts-node/register --exit "$TESTS" 2>&1 > test.log &
else
	npx mocha -r ts-node/register --exit "$TESTS"
fi
