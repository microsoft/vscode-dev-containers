# Ruby & Sinatra (Community)

## Summary

*Develop Ruby and Sinatra applications. Includes everything you need to get up and running.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Amblizer][la] |
| *Categories* | Community, Frameworks |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Ruby |

## Using this definition

While this definition should work unmodified, you can select the version of Ruby the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "2.7" }
```

### Installing Node.js

Given JavaScript front-end web client code written for use in conjunction with a Ruby back-end often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.

```jsonc
"args": {
    "VARIANT": "2",
    "NODE_VERSION": "14" // Set to "none" to skip Node.js installation
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
4. Select the `containers/ruby-sinatra` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "Try http://localhost:4567/ in the browser!" in the Debug Console. Press <kbd>F1</kbd>. Select **Forward a Port** then choose **Forward 4567**, and by browsing http://localhost:4567/ you should see "Hello from Sinatra!".
7. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).

<!-- links -->
[la]: https://code.mzhao.page/
