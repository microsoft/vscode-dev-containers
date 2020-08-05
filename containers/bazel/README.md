# Bazel

## Summary

*Develop and compile efficiently on any language with the Bazel compilation tool.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | William Phetsinorath <deva.shikanime@protonmail.com> |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Any |

## Using this definition with an existing folder

While this definition works unmodified, you can set the Bazel verison by updating the `BAZEL_VERSION` argument in `devcontainer.json`.

```json
"args": {
   "BAZEL_VERSION": "3.4.1"
}
```

Optionally, you can validate the SHA256 checksum for `bazel-installer.sh` by adding it to the `BAZEL_DOWNLOAD_SHA` argument:

```json
"args": {
   "BAZEL_VERSION": "3.4.1",
   "BAZEL_DOWNLOAD_SHA": "9808adad931ac652e8ff5022a74507c532250c2091d21d6aebc7064573669cc5"
}
```

### Adding the definition to your folder

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Dart definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of this folder in the cloned repository to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select this folder from the cloned repository.
5. Press <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>\`</kbd> and type the following command to verify installation: `bazel run //test-project:hello-world`
6. You should see "Hello remote world!" in the Debug Console after the program executes.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).