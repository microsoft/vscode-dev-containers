# Jekyll

## Summary

*Develop static sites with Jekyll, includes everything you need to get up and running.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Carlos Mendible](https://github.com/cmendible), [parkr](https://github.com/parkr) |
| *Categories* | Community, Languages, Frameworks |
| *Definition type* | Dockerfile |
| *Published images* | mcr.microsoft.com/vscode/devcontainers/jekyll |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Ruby, Jekyll |

See **[history](history)** for information on the contents of published images.

## Using this definition

In addition to Ruby and Bundler, this development container installs Jekyll and the required tools at startup:

- If your Jekyll project contains a `Gemfile` in the root folder, the development container will install all gems at startup by running `bundle install`. This is the [recommended](https://jekyllrb.com/docs/step-by-step/10-deployment/#gemfile) approach as it allows you to specify the exact Jekyll version your project requires and list all additional Jekyll plugins.
- If there's no `Gemfile`, the development container will install Jekyll automatically, picking the latest version. You might need to manually install the other dependencies your project relies on, including all relevant Jekyll plugins.

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `mcr.microsoft.com/vscode/devcontainers/jekyll:0`
- `mcr.microsoft.com/vscode/devcontainers/jekyll:0.0`
- `mcr.microsoft.com/vscode/devcontainers/jekyll:0.0.1`

See [history](history) for information on the contents of each version and [here for a complete list of available tags](https://mcr.microsoft.com/v2/vscode/devcontainers/jekyll/tags/list).

Alternatively, you can use the contents of `base.Dockerfile` to fully customize your container's contents or to build it for a container host architecture not supported by the image.

### Installing Node.js

Given JavaScript front-end web client code written for use in conjunction with a Jekyll site often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.

```json
"args": {
    "NODE_VERSION": "10"
}
```

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
