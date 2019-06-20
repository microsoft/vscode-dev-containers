@ECHO OFF
REM -------------------------------------------------------------
REM  Copyright (c) Microsoft Corporation. All rights reserved.
REM -------------------------------------------------------------
SETLOCAL

SET HELP=0
IF "%1"=="--help" ( SET HELP=1 )
IF "%1"=="help" ( SET HELP=1 )
IF "%1"=="/help" ( SET HELP=1 )
IF "%1"=="/?" ( SET HELP=1 )
IF %HELP% EQU 1 (
	echo test.cmd [--trace] [background] [^<definition/template/try^> [definition ID/template name/try repo]]
	EXIT /B 0
)

SET "CURDIR=%CD%"
CD "%~dp0"

IF NOT EXIST node_modules (
 	CALL yarn install
)

SET COMMAND=yarn test

IF "%1"=="--trace" (
	SET TEST_LOG_LEVEL=trace
	shift
)

IF "%1"=="background" (
	SET RUN_IN_BACKGROUND=1
	shift
)

SET TESTS=src/**/*.test.ts
IF "%1"=="definition" (
	SET TESTS=src/devContainerDefinitions.test.ts
	SET TEMPLATES_TO_TEST=none
	SET DEFINITIONS_TO_TEST=$2
	SET TRY_REPOS_TO_TEST=none
)
IF "%1"=="template" (
	SET TESTS=src/devContainerTemplates.test.ts
	SET TEMPLATES_TO_TEST=%2
	SET DEFINITIONS_TO_TEST=none
	SET TRY_REPOS_TO_TEST=none
)
IF "%1"=="try" (
	SET TESTS=src/tryRepositories.test.ts
	SET TEMPLATES_TO_TEST=none
	SET DEFINITIONS_TO_TEST=none
	SET TRY_REPOS_TO_TEST=%2
)
IF "%1"=="template" (
	SET TEST_TYPE=%1
	SET DEVCONTAINER_TEMPLATE_NAME=%2
	SET DEVCONTAINER_NAME=none
	SET TRY_REPO_NAME=none
)

IF %RUN_IN_BACKGROUND% EQU 1 (
	START npx mocha -r ts-node/register --exit "%TESTS%" 2^>^&1 ^> test.log
)
ELSE (
	CALL npx mocha -r ts-node/register --exit "%TESTS%"
)

CD "%CURDIR%"