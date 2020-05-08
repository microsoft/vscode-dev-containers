# ReasonML

## Summary

*Develop ReasonML applications.*

| Metadata | Value |
|----------|-------|
| *Contributors* | Diullei Gomes ([@diullei](https://github.com/diullei)) |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | No |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | ReasonML |

This image contains the development environment to work with [ReasonML](https://reasonml.github.io/) applications. It also includes [fish shell](https://fishshell.com/) to improve the CLI experience.

## Using this definition with an existing folder

To get started, follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the ReasonML definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/reasonml/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/reasonml` folder.
5. After the folder has opened in the container, use the following commands:

```bash
   cd test-project
   yarn install
   yarn build
   node src/Demo.bs.js
```

6. You should see: "Hey, Dev!" as the application output.

> NOTE: You can type `fish` to the cli to use the [fish shell](https://fishshell.com/).

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).