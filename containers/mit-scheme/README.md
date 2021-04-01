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

## Using this definition with an existing folder

While the definition itself works unmodified, you can select the version of MIT-SCHEME uses by updating the `TARGET_SCHEME_VERSION` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "TARGET_SCHEME_VERSION": "11.1" }
```

Beyond `git`, this image / `Dockerfile` includes `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

### Adding the definition to your project

Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use the Dockerfile for this definition (*rather than the pre-built image*):
   1. Clone this repository.
   2. Copy the contents of `containers/mit-scheme/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

3. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

4. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.


## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE)
