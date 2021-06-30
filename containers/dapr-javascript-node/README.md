# Dapr with Node.js & JavaScript (Community)

## Summary

*Develop Dapr applications using Node.js and JavaScript. Includes Dapr, Node.js, eslint, yarn, and the TypeScript compiler.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The Visual Studio Container Tools team |
| *Categories* | Community, Frameworks |
| *Definition type* | Docker Compose |
| *Works in Codespaces* | No |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Node.js, TypeScript, Dapr |

## Dapr Notes

When the dev container is created, the definition automatically initializes Dapr on a separate Docker network (to isolate it from Dapr instances running locally or in another Dapr dev container). This is done via the `postCreateCommand` in the `.devcontainer/devcontainer.json` and the `DAPR_NETWORK` environment variable in the `.devcontainer/docker-compose.yml`.

## Using this definition

This definition installs `tslint` globally and includes the VS Code TSLint extension for backwards compatibility, but [TSLint has been deprecated](https://github.com/palantir/tslint/issues/4534) in favor of ESLint, so `eslint` and its corresponding extension has been included as well.

Both `eslint`and `typescript` are installed globally for convenance, but [as of ESLint 6](https://eslint.org/docs/user-guide/migrating-to-6.0.0#-plugins-and-shareable-configs-are-no-longer-affected-by-eslints-location), you will need to install the following packages locally to lint TypeScript code: `@typescript-eslint/eslint-plugin`, `@typescript-eslint/parser`, `eslint`, `typescript`.

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**. 

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/dapr-typescript-node-12` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project. This will automatically run `npm install` and compile the source before starting it.
6. In a separate terminal, invoke the application via Dapr:

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

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).