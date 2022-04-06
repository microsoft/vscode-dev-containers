# Scala (Community)

## Summary

*Develop Scala applications. Includes the Metals and Scala Syntax extensions.*

| Metadata                    | Value                 |
|-----------------------------|-----------------------|
| *Contributors*              | @heksesang            |
| *Categories*                | Community, Languages  |
| *Definition Type*           | Dockerfile            |
| *Works in Codespaces*       | Yes                   |
| *Container host OS support* | Linux, MacOS, Windows |
| *Container OS*              | Debian                |
| *Languages, platforms*      | Scala                 |

## Using this definition

While this definition should work unmodified, you can select the version of Java the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
// Or you can use 17-bullseye or 17-buster if you want to pin to an OS version
"args": { "VARIANT": "17" }
```

### Installing a specific Scala Version

You can set the default Scala version that is pre-loaded with Scala CLI by adding the `"SCALA_VERSION"` to the build arguments in `.devcontainer/devcontainer.json`.

```json
"args": {
   "SCALA_VERSION": "2.13.5"
}
```

### Installing Mill

Mill can be installed by setting the `"INSTALL_MILL"` build argument to true in `.devcontainer/devcontainer.json`.

```json
"args": {
   "INSTALL_MILL": "true"
}
```

### Installing SBT

SBT can be installed by setting the `"INSTALL_SBT"` build argument to true in `.devcontainer/devcontainer.json`.

```json
"args": {
   "INSTALL_SBT": "true"
}
```

### Installing Clang

Scala Native is a compiler for Scala that targets native code, and depends on the Clang compiler frontend. You can enable support for this by setting the `"INSTALL_CLANG"` build argument to true in `.devcontainer/devcontainer.json`.

```json
"args": {
   "INSTALL_CLANG": "true"
}
```

### Adding the definition to your folder

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. Clone this repository.

3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**

4. Select the `containers/scala` folder.

5. After the folder has opened in the container, press <kbd>Ctrl-Shift-`</kbd>
   to open a new terminal.

6. Run the following command to execute a simple application.
   ```bash
   scala-cli run test-project
   ```

7. You should see "Hello world!" in the terminal after the program executes.

8. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
