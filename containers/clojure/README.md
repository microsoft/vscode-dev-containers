# Clojure

## Summary

*Develop Clojure applications. Includes the Calva and clj-kondo extensions.*

| Metadata                    | Value                 |
|-----------------------------+-----------------------|
| *Categories*                | Core, Languages       |
| *Definition Type*           | Dockerfile            |
| *Works in Codespaces*       | Yes                   |
| *Container host OS support* | Linux, MacOS, Windows |
| *Container OS*              | Debian                |
| *Languages, platforms*      | Clojure               |

## Using this definition

While this definition should work unmodified, you can select the version of Java the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
// Or you can use 16-bullseye or 16-buster if you want to pin to an OS version
"args": { "VARIANT": "16" }
```

## Installing Clojure CLI Tools

The Clojure command line tools will be installed by default but you can change this behavior by adding
`"INSTALL_LEININGEN: \"false\""` to the build args in 
`.devcontainer/devcontainer.json`.

```json
"args": {
   "VARIANT": "11",
   "INSTALL_CLOJURE_CLI": "false"
}
```

## Installing Leiningen

Leiningen will be installed by default but you can change this behavior by adding
`"INSTALL_LEININGEN: \"false\""` to the build args in 
`.devcontainer/devcontainer.json`.

```json
"args": {
   "INSTALL_LEININGEN": "false"
}
```

### Adding the definition to your folder

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. To use the pre-built image:
   1. Start VS Code and open your project folder or connect to a codespace.
   2. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.
   4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

3. To build a custom version of the image instead:
   1. Clone this repository locally.
   2. Start VS Code and open your project folder or connect to a codespace.
   3. Use your local operating system's file explorer to drag-and-drop the locally cloned copy of the `.devcontainer` folder for this definition into the VS Code file explorer for your opened project or codespace.
   4. Update `.devcontainer/devcontainer.json` to reference `"dockerfile": "base.Dockerfile"`.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/clojure` folder.
5. Open the "test-project" folder and click on the "project.clj" file to open the project file.
6. Open the command palette and choose "Calva: Start a Project REPL and Connect (aka Jack-In)".
7. When prompted for a project type, choose "Leiningen".
7. A new Clojure REPL panel will appear, type "(main)" and press "alt+enter".
8. You should see "Hello from the test project!" in the a Debug Console after the program executes.
9. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).