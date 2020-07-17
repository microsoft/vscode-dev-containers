# Python 3 with Pipenv

## Summary

_Develop Python 3 applications, tracking default and dev packages using [Pipenv](https://pipenv.pypa.io/en/latest/)_.

| Metadata                     | Value                                               |
| ---------------------------- | --------------------------------------------------- |
| _Contributors_               | [Michael Galliers](https://github.com/KYDronePilot) |
| _Definition type_            | Dockerfile                                          |
| _Base image architecture(s)_ | x86-64                                              |
| _Works in Codespaces_        | Yes                                                 |
| _Container Host OS Support_  | Linux, macOS, Windows                               |
| _Languages, platforms_       | Python                                              |

## Using this definition with an existing folder

### Configuration

While the definition itself works unmodified, you can select the version of Python the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "3.8" }
```

Beyond Python and `git`, this `Dockerfile`'s base image includes a number of Python tools, `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

The included `Dockerfile` installs Pipenv. On completion of creating the container, Pipenv is run to create a new environment inside the container and install the same Python tools mentioned above as dev packages. Once the container is running, the Python extension should recognize the Pipenv environment. You can then use Pipenv to manage packages like normal with the integrated terminal:

```bash
pipenv install --dev prospector
pipenv install Flask
```

#### Managing Python tools with Pipenv

By default, Pipenv installs the same tools as are in the base `python-3` dev container image as dev packages. If there is an existing `Pipfile`, these packages will be added to it. If not, a new Pipfile will be created, to which they will be added.

If you don't want certain tools installed, remove them from the `postCreateCommand` setting in the `devcontainer.json` config.

Once the container has been created the first time, the tools are in your Pipfile and can be removed from the `postCreateCommand` so it looks like this:

```json
"postCreateCommand": "pipenv install --dev && ln -s ~/.local/share/virtualenvs/*-* ~/.local/share/pipenv"
```

#### Debug Configuration

Note that only the integrated terminal is supported by the Remote - Containers extension. You may need to modify `launch.json` configurations to include the following value if an external console is used.

```json
"console": "integratedTerminal"
```

#### Using the forwardPorts property

By default, frameworks like Flask only listens to localhost inside the container. As a result, we recommend using the `forwardPorts` property (available in v0.98.0+) to make these ports available locally.

```json
"forwardPorts": [5000]
```

The `appPort` property [publishes](https://docs.docker.com/config/containers/container-networking/#published-ports) rather than forwards the port, so applications need to listen to `*` or `0.0.0.0` for the application to be accessible externally. This conflicts with the defaults of some Python frameworks, but fortunately the `forwardPorts` property does not have this limitation.

If you've already opened your folder in a container, rebuild the container using the **Remote-Containers: Rebuild Container** command from the Command Palette (<kbd>F1</kbd>) so the settings take effect.

### Adding the definition to your project

Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Start VS Code and open your project folder.
3. Press <kbd>F1</kbd> and select **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
4. Select the **Python 3 with Pipenv** definition.
5. The contents of the `.devcontainer` folder in your project can now be adapted to meet your needs.
6. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/python-3-pipenv` folder.
5. After the folder has opened in the container, open the `test-project/hello.py` file.
6. Press <kbd>F1</kbd> and select **Python: Run Python File in Terminal** from the command palette.
7. You should see "Hello from Pipenv!" in a terminal window after the program executes.
8. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE)
