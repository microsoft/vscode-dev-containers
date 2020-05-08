# Dapr with Node.js 12 & TypeScript

## Summary

*Develop Dapr applications using Node.js 12 and TypeScript. Includes Dapr, Node.js, eslint, yarn, and the TypeScript compiler.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The Visual Studio Container Tools team |
| *Definition type* | Docker Compose |
| *Works in Codespaces* | No ([#457](https://github.com/MicrosoftDocs/vsonline/issues/457)) |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Node.js, TypeScript, Dapr |

## Dapr Notes

When the dev container is created, the definition automatically initializes Dapr on a separate Docker network (to isolate it from Dapr instances running locally or in another Dapr dev container). This is done via the `postCreateCommand` in the `.devcontainer/devcontainer.json` and the `DAPR_NETWORK` environment variable in the `.devcontainer/docker-compose.yml`. The `DAPR_REDIS_HOST` and `DAPR_PLACEMENT_HOST` environment variables ensure that Dapr `run` commands implicitly connect to the Dapr instance in that Docker network.

## Using this definition with an existing folder

This definition installs `tslint` globally and includes the VS Code TSLint extension for backwards compatibility, but [TSLint has been deprecated](https://github.com/palantir/tslint/issues/4534) in favor of ESLint, so `eslint` and its corresponding extension has been included as well.

Both `eslint`and `typescript` are installed globally for convenance, but [as of ESLint 6](https://eslint.org/docs/user-guide/migrating-to-6.0.0#-plugins-and-shareable-configs-are-no-longer-affected-by-eslints-location), you will need to install the following packages locally to lint TypeScript code: `@typescript-eslint/eslint-plugin`, `@typescript-eslint/parser`, `eslint`, `typescript`.

To get started, follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Dapr with Node.js 12 & TypeScript definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/dapr-typescript-node-12/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/dapr-typescript-node-12` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project. This will automatically run `npm install` and compile the source before starting it.
6. Start the application with Dapr:

    ```bash
    $ cd test-project
    $ npm run dapr
    ```

7. In a separate terminal, invoke the application via Dapr:

    ```bash
    # Deposit funds to the account (creating the account if not exists)
    $ curl -d 42 -H "Content-Type: application/json" -w "\n" -X POST http://localhost:3500/v1.0/invoke/test/method/accounts/123/deposit
    42
    # Withdraws funds from the account
    $ curl -d 10 -H "Content-Type: application/json" -w "\n" -X POST http://localhost:3500/v1.0/invoke/test/method/accounts/123/withdraw
    32
    # Get the balance of the account
    $ curl -w "\n" http://localhost:3500/v1.0/invoke/test/method/accounts/123
    32
    $
    ```

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).