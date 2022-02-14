# Bazel (Community)

## Summary

*Develop and compile efficiently on any language with the Bazel compilation tool.*

| Metadata                    | Value                                                |
| --------------------------- | ---------------------------------------------------- |
| *Contributors*              | William Phetsinorath <deva.shikanime@protonmail.com> |
| *Categories*                | Community, Other                                     |
| *Definition type*           | Dockerfile                                           |
| *Supported architecture(s)* | x86-64                                               |
| *Works in Codespaces*       | Yes                                                  |
| *Container host OS support* | Linux, macOS, Windows                                |
| *Container OS*              | Debian                                               |
| *Languages, platforms*      | Any                                                  |

## Using this definition

While this definition works unmodified, you can set the Bazelisk version by updating the `BAZELISK_VERSION` argument in `devcontainer.json`.

```json
"args": {
   "BAZELISK_VERSION": "v1.10.1"
}
```

Optionally, you can validate the SHA256 checksum for `bazelisk` executable by adding it to the `BAZELISK_DOWNLOAD_SHA` argument:

```json
"args": {
   "BAZELISK_VERSION": "v1.10.1",
   "BAZELISK_DOWNLOAD_SHA": "4cb534c52cdd47a6223d4596d530e7c9c785438ab3b0a49ff347e991c210b2cd"
}
```

### Adding the definition to your folder

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
4. Select this folder from the cloned repository.
5. Press <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>\`</kbd> and type the following command to verify installation: `bazelisk run //test-project:hello-world`
6. You should see "Hello remote world!" in the Debug Console after the program executes.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).