# Java

## Summary

*Develop Java applications. Includes the JDK and Java extensions.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Java Team |
| *Definition type* | Dockerfile |
| *Published images* | mcr.microsoft.com/vscode/devcontainers/java |
| *Available image variants* | 11, 15 |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Java |

## Using this definition with an existing folder

> **Note:** A version of this [definition for **JDK 8**](../java-8) is also available!

While this definition should work unmodified, you can select the version of Java the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "15" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own  `Dockerfile` to one of the following. An example `Dockerfile` is included in this repository.

- `mcr.microsoft.com/vscode/devcontainers/java` (latest)
- `mcr.microsoft.com/vscode/devcontainers/java:11`
- `mcr.microsoft.com/vscode/devcontainers/java:15`

Version specific tags tied to [releases in this repository](https://github.com/microsoft/vscode-dev-containers/releases) are also available.

- `mcr.microsoft.com/vscode/devcontainers/java:0-11`
- `mcr.microsoft.com/vscode/devcontainers/ruby:0.135-11`
- `mcr.microsoft.com/vscode/devcontainers/ruby:0.135.0-11`

Alternatively, you can use the contents of `base.Dockerfile` to fully customize your container's contents or to build it for a container host architecture not supported by the image.

### Debug Configuration

Note that only the integrated terminal is supported by the Remote - Containers extension. You may need to modify `launch.json` configurations to include the following value if an external console is used.

```json
"console": "integratedTerminal"
```

### Installing Maven or Gradle

You can opt to install a version of Maven or Gradle by adding `"INSTALL_MAVEN: "true"` or `"INSTALL_GRADLE: "true"` to build args in `.devcontainer/devcontainer.json`. Both of these are set by default. For example:

```json
"args": {
   "VARIANT": "11",
   "INSTALL_GRADLE": "true",
   "INSTALL_MAVEN": "true"
}
```

Remove the appropriate arg or set its value to `"false"` to skip installing the specified tool.

You can also specify the version of Gradle or Maven if needed.

```json
"args": {
   "VARIANT": "11",
   "INSTALL_GRADLE": "true",
   "MAVEN_VERSION": "3.6.3",
   "INSTALL_MAVEN": "true",
   "GRADLE_VERSION": "5.4.1"
}
```

### Installing Node.js

Given how frequently web applications use Node.js for front end code, this container also includes an optional install of Node.js. You can enable installation and change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.

```json
"args": {
   "VARIANT": "11",
    "INSTALL_NODE": "true",
    "NODE_VERSION": "10",
}
```

### Adding the definition to your folder

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Java definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/java/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/java` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "Hello Remote World!" in the a Debug Console after the program executes.
7. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
