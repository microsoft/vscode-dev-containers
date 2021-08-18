# MIT-Scheme (Community)

## Summary

*Simple mit-scheme container with Git installed.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Aisuko](https://github.com/Aisuko) |
| *Categories* | Community |
| *Definition type* | Dockerfile |
| *Architecture(s)* | x86-64 |
| *Works in Codespaces* | No |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | MIT-Scheme |

## Using this definition

While the definition itself works unmodified, you can select the version of MIT-SCHEME uses by updating the `TARGET_SCHEME_VERSION` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "TARGET_SCHEME_VERSION": "11.1" }
```

Beyond `git`, this image / `Dockerfile` includes `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

### Adding the definition to a project or codespace

Just follow these steps:

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE)
