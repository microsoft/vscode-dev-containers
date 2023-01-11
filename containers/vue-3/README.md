# Vue 3 (Community)

## Summary

_Reproducible, containerized environment for Vue.js 3 frontend development._

| Metadata                    | Value                                        |
| --------------------------- | -------------------------------------------- |
| _Contributors_              | [Florian Kromer](https://github.com/fkromer) |
| _Categories_                | Community, Frameworks                        |
| _Definition type_           | Dockerfile                                   |
| _Works in Codespaces_       | Yes                                          |
| _Container host OS support_ | Linux, macOS, Windows                        |
| _Container OS_              | Debian                                       |
| _Languages, platforms_      | Vue.js 3, TypeScript                         |

## Description

This development container aims at providing a reproducible development environment for Vue.js 3 apps in VSCode on Linux, Mac and Windows while providing a powerful Debian based shell environment.

### Features

- [x] Based on `typescript-node` container image (`git`, `zsh`, `oh-my-zsh`, etc.)
- [x] Command-line fuzzy finder [fzf](https://github.com/junegunn/fzf)
- [x] Code-searching tool [ag](https://github.com/ggreer/the_silver_searcher)
- [x] Support for custom `dotfiles`
- [x] [npm](https://www.npmjs.com/) (provided by base image)
- [x] [yarn](https://yarnpkg.com/) (provided by base image)
- [x] [Vue.js 3](https://github.com/vuejs/vue-next) aka `vue-next` (including `compiler-sfc`, etc.)
- [x] [Ionic Framework (Vue)](https://ionicframework.com/docs/vue/overview)
- [x] [Gridsome](https://gridsome.org/)
- [x] [VSCode Extension Vetur](https://marketplace.visualstudio.com/items?itemName=octref.vetur)
- [ ] VSCode Settings for Vetur [configuration info](https://vuejs.github.io/vetur/guide/setup.html#vs-code-config)
- [x] [VSCode Extension ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [ ] VSCode Settings for ESLint [configuration info](https://github.com/microsoft/vscode-eslint/blob/main/history/settings_1_9_x.md)
- [x] [VSCode Extension Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
- [ ] VSCode Settings for Prettier [configuration info](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode#prettier-settings)
- [x] [Visual Studio IntelliCode](https://marketplace.visualstudio.com/items?itemName=visualstudioexptteam.vscodeintellicode)
- [x] Container image tests
- [x] Test project

The globally installed `npm` packages have been kept to a minimum.
Of course you can use other common tools by installing into project specific environments:

- [Vite](https://vitejs.dev/guide/#scaffolding-your-first-vite-project)
- [VuePress](https://vuepress.vuejs.org/guide/getting-started.html#manual-installation)
- [Saber](https://saber.land/docs/installation.html#creating-a-new-project-from-scratch)

## Using this definition

While the definition itself works unmodified, you can customize the container with `args` in the included `.devcontainer/devcontainer.json` file.

This container uses the `typescript-node` container as base container. For more info about available customization options via `args` refer to the [usage instructions](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/typescript-node#using-this-definition).

> Beyond TypeScript, Node.js, and `git`, this image / `Dockerfile` includes `eslint`, `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development. Since `tslint` is now fully depreicated, the definition includes `tslint-to-eslint-config` globally to help you migrate.
>
> Note that, while eslintand typescript are installed globally for convenance, as of ESLint 6, you will need to install the following packages locally to lint TypeScript code: @typescript-eslint/eslint-plugin, @typescript-eslint/parser, eslint, typescript.

This container's overall customization options via `args` are as follows. The values shown are the default values.

### Configuration: Debian version

```json
"args": { "VARIANT": "latest" }
```

More info about [valid values](https://mcrflowprodcentralus.data.mcr.microsoft.com/mcrprod/vscode/devcontainers/typescript-node?P1=1627143043&P2=1&P3=1&P4=5TQ%2B5GHJS4tUC0eBZ4jTxKeU%2Bi9Ng9LEPIHHbtcSemU%3D&se=2021-07-24T16%3A10%3A43Z&sig=XEyqxn2SkBgIj2%2FMFlsOvV6IA76PVNijFWdNMLB%2B8OE%3D&sp=r&sr=b&sv=2015-02-21)...

### Configuration: Vue.js 3 version

```json
"args": { "VUE_VERSION": "next" }
```

More info about [valid values](https://www.npmjs.com/package/vue?activeTab=versions) (the ones with major version 3)...

### Configuration: Compiler SFC version

```json
"args": { "COMPILER_SFC_VERSION": "latest" }
```

More info about [valid values](https://www.npmjs.com/package/@vue/compiler-sfc?activeTab=versions) (the ones with major version 3)...

### Configuration: Ionic framework version

```json
"args": { "IONIC_VERSION": "latest" }
```

More info about [valid values](https://www.npmjs.com/package/@ionic/cli?activeTab=versions)...

### Configuration: VuePress version

```json
"args": { "VUEPRESS_VERSION": "next" }
```

More info about [valid values](https://www.npmjs.com/package/vuepress?activeTab=versions)...

### Configuration: dotfiles

Create a Git repository containing your `dotfiles` and containing an `install.sh` script if required.
In `.vscode/settings.json` adjust `"remote.containers.dotfiles.repository": "https://github.com/fkromer/vue-3-dotfiles"`
to your Git repository.

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

   > **Note**: For usage in a local VSCode installation install [VSCode Extension Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) on the host machine. In case of usage of WSL2 on Windows the host machine is Windows, not the WSL2 Linux distribution.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

   > **Note:** As long this repository is no officially supported dev container the folders `.devcontainer` and `.vscode` need to be copied into a local project folder. Refer to the configuration instructions above.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/main/LICENSE).
