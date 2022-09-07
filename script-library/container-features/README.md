**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated a set of Features to a new [devcontainers/features](https://github.com/devcontainers/features) repo.**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Container Features

This folder includes some explorations around dynamic container feature injection. Nothing stable yet.

## Contributing to Container Features

### Creating a new feature

**Registering a feature**

Create the install script in the [script-library](../../script-library/) directory with the naming convention `<lowercase-feature-name>-<target-os>.sh`. E.g., `python-debian.sh` or `common-alpine.sh`

Add a new object to the [devcontainer-features.json](../../script-library/container-features/src/devcontainer-features.json) file:

```json
{
    "id": "<lowercase-feature-name>", // Must match the <lowercase-feature-name> used to name the install script.
    "name": "Display Name of Feature",
    "documentationURL": "https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/<lowercase-feature-name>.md",
    "options": {
        "scriptArgument$1": {
            "type": "string", // Either "string" or "boolean"
            "proposals": [], // Array of valid string values for this option.
            "default": "", // Default value if user does not specify.
            "description": "" // User-facing description of this option.
        },
        "scriptArgument$2": {
            "type":"boolean", // Either "string" or "boolean"
            "default": false, // Either true or false
            "description": "" // User-facing description of this option.
        }
    },
    "buildArg": "_VSC_INSTALL_<CAPITALIZED_ID>", // Must match the ENV VAR defined in the feature-scripts.env file.
    "extensions": [], // Array of VS Code extensions to install with this feature.
    "include": [] // Array of base containers this script can be used on.
}
```

Add your buildArg to the [feature-scripts.env](../../script-library/container-features/src/feature-scripts.env) file with all script arguments specified (even if they duplicate a script default).

```
_VSC_INSTALL_<FEATURE>="<feature>-debian.sh ${_BUILD_ARG_<FEATURE>_<OPTION1>:-<option1 default>} ${_BUILD_ARG_<FEATURE>_<OPTION2>:-<option2 default>} hardcodedThirdArgument"
```

- Options declared in `devcontainer-features.json` are mapped using the naming convention `_BUILD_ARG_<FEATURE>_<OPTIONNAME>` and their default should match the declared default for that option.
- E.g., `_VSC_INSTALL_AZURE_CLI="azcli-debian.sh ${_BUILD_ARG_AZURE_CLI_VERSION:-latest}"`

**Feature testing**

*Local testing*

- Create a devcontainer with a target base image.
- Add your script to the root.
- Bring up the container image.
- Run your script in the container with required arguments.
- Verify expected results.
- Bring down container to clean up.

Repeat as needed to iterate from a clean workspace.

*Unit tests*

- Add your feature to the [run-scripts.sh](../../script-library/test/regression/run-scripts.sh) file to ensure it is included in CI tests.

- Your addition should take the form `runScript <feature> <non-default-args>`.

E.g.:

```sh
runScript dotnet "3.1 true ${USERNAME} false /opt/dotnet dotnet"
```

- If your script takes the installation user as an argument, be sure to specify it as ${USERNAME} in the tests for programatic testing.

*Regression tests*

- Add your feature to the [test-features.env](../../script-library/container-features/test-features.env) file to include it in regression tests of the container-feature functionality. By setting the `_VSC_INSTALL_<FEATURE>` ENV VAR to true and adding the expected _BUILD_ARG options for your feature.

E.g.:

```
    _VSC_INSTALL_DOTNET=true
    _BUILD_ARG_DOTNET_VERSION=latest
    _BUILD_ARG_DOTNET_RUNTIMEONLY=false
```

**Feature documentation**

Add your new feature to the list of scripts in the [script-library README.md](../../script-library/README.md#scripts).

Add documentation for your new feature script to the [script-library/docs](../../script-library/docs) directory.

Documentation should include:

- the status of the script, supported operating systems, and maintainer.
- the syntax expected to run as a feature or script
- a description of the script arguments
- detailed usage instructions

Feel free to use other scripts in that directory as inspiration.

### Best practices for writing feature install scripts

- Decouple sections of the shellscript that handle user setup, helper functions, and feature installation. Doing so will apply a logical and natural flow to the script for future developers and maintainers to follow. One way to denote this distinction is to use in-line comments throughout the script.

    ```md
    # Logical flow recommended:
    1. File header and description.
    2. Define constants and default values.
    3. User setup and user validation.
    4. Helper functions.
    5. Checks for dependencies being installed or installs dependencies.
    6. Runs container feature installs.
    7. Gives the user correct permissions if necessary.
    ```

- One way to make troubleshooting the script easier when writing a bash shell script is to echo error messages to `STDERR`. A possible way we implemented this in bash scripts is to create an `err()` function like so:

    ```sh
    # Setup STDERR.
    err() {
        echo "(!) $*" >&2
    }
    err "Something went wrong!"
    exit 1
    ```

- If writing a bash shellscript, we recommend using double quotes and braces when referencing named variables:

    ```sh
    variable="My example var"
    echo "${variable}"
    ```

- One method to to ensure the global space in a script is not too crowded with unnecessary variables is to assign return values from functions to a new variable, and use the keyword `local` for vars inside of functions. For example:

    ```sh
    test_function() {
        local test = "hello world!"
        echo "${test}"
    }
    global_test=$(test_function)
    ```

- If using temporary files within the script, we recommend removing all those files once they are no longer needed. One method for doing this is running a cleanup function with a `trap` method when the script exits:

    ```sh
    # Cleanup temporary directory and associated files when exiting the script.
    cleanup() {
        EXIT_CODE=$?
        set +e
        if [[ -n "${TMP_DIR}" ]]; then
            echo "Executing cleanup of tmp files"
            rm -Rf "${TMP_DIR}"
        fi
        exit $EXIT_CODE
    }
    trap cleanup EXIT
    ```

- Consider using [shellcheck](https://github.com/koalaman/shellcheck) or the [vscode-shellcheck extension](https://github.com/vscode-shellcheck/vscode-shellcheck) to apply linting and static code analysis to the bash script to ensure it is formatted correctly.

- Consider using common helper functions from [shared/utils.sh](../../script-library/shared/utils.sh) when managing common tasks (like updating PATH variables, or managing gpg keys) by copying them directly into your script.
    - NOTE: This is done to minimize the impact that any change can have on existing working scripts.
    - Similarly, if you add a helper function to your script that could benefit others in the future, consider adding it to the `shared/utils.sh` file as well.

- [shared/settings.env](../../script-library/shared/settings.env) contains shared environment variables used in many install scripts, such as `GPG Keys` and `Archive Architectures`. Consider adding your new env. variables to this script when applicable, or reusing existing variables when pertinent.
