# Node.js & TypeScript

## Summary

*Develop Node.js based applications in TypeScript. Includes Node.js, eslint, nvm, yarn, and the TypeScript compiler.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Definition type* | Dockerfile |
| *Published image* | mcr.microsoft.com/vscode/devcontainers/typescript-node:14 |
| *Available image variants* |  mcr.microsoft.com/vscode/devcontainers/typescript-node:14<br />mcr.microsoft.com/vscode/devcontainers/typescript-node:12<br />mcr.microsoft.com/vscode/devcontainers/typescript-node:10 |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Node.js, TypeScript |

## Using this definition with an existing folder

While the definition itself works unmodified, you can select the version of Node.js the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "12" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own `Dockerfile` with one of the following:

- `mcr.microsoft.com/vscode/devcontainers/typescript-node` (latest)
- `mcr.microsoft.com/vscode/devcontainers/typescript-node:14`
- `mcr.microsoft.com/vscode/devcontainers/typescript-node:12`
- `mcr.microsoft.com/vscode/devcontainers/typescript-node:10`


Version specific tags tied to [releases in this repository](https://github.com/microsoft/vscode-dev-containers/releases) are also available.

- `mcr.microsoft.com/vscode/devcontainers/typescript-node:0-14`
- `mcr.microsoft.com/vscode/devcontainers/typescript-node:0.123-14`
- `mcr.microsoft.com/vscode/devcontainers/typescript-node:0.123.0-14`

Alternatively, you can use the contents of the `Dockerfile` or the [JavaScript and Node.js `Dockerfile`](../javascript-node/.devcontainer/base.Dockerfile) to fully customize your container's contents.

Beyond TypeScript, Node.js, and `git`, this image / `Dockerfile` includes `eslint`, `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development. It also installs `tslint` globally and includes the VS Code TSLint extension for backwards compatibility, but [TSLint has been deprecated](https://github.com/palantir/tslint/issues/4534) in favor of ESLint, so `eslint` and its corresponding extension has been included as well.

Note that, while `eslint`and `typescript` are installed globally for convenance, but [as of ESLint 6](https://eslint.org/docs/user-guide/migrating-to-6.0.0#-plugins-and-shareable-configs-are-no-longer-affected-by-eslints-location), you will need to install the following packages locally to lint TypeScript code: `@typescript-eslint/eslint-plugin`, `@typescript-eslint/parser`, `eslint`, `typescript`.

### Adding the definition to your project

Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use the pre-built image:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Node.js 14 & TypeScript definition.

3. To use the Dockerfile for this definition (*rather than the pre-built image*):
   1. Clone this repository.
   2. Copy the contents of `containers/typescript-node/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/typescript-node` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project. This will automatically run `npm install` and compile the source before starting it.
6. Once the project is running, press <kbd>F1</kbd> and select **Remote-Containers: Forward Port from Container...**
7. Select port 3000 and click the "Open Browser" button in the notification that appears.
8. You should see "Hello remote world!" after the page loads.
9. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
