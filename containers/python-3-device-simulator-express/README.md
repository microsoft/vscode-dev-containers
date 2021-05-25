# Python 3 & Device Simulator Express (Community)

## Summary

*Develop for circuit boards, with or without a physical device using Python 3 and [Device Simulator Express](https://www.microsoft.com/en-us/garage/profiles/device-simulator-express/)*

| Metadata | Value |
|----------|-------|
| *Contributors* | [Carlos Mendible](https://github.com/cmendible) |
| *Categories* | Community, Other |
| *Definition type* | Dockerfile |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container Host OS Support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Python |

## Using this definition

### Configuration

While the definition itself works unmodified, you can select the version of Python the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "3.8" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own `Dockerfile` with one of the following:

- `mcr.microsoft.com/vscode/devcontainers/python:3` (latest)
- `mcr.microsoft.com/vscode/devcontainers/python:3.7`
- `mcr.microsoft.com/vscode/devcontainers/python:3.8`

Alternatively, you can use the contents of `base.Dockerfile` to fully customize the your container's contents or build for a container architecture the image does not support.

Beyond Python and `git`, this image / `Dockerfile` includes a number of Python tools, `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

#### Installing or updating Python utilities

This container installs all Python development utilities using [pipx](https://pipxproject.github.io/pipx/) to avoid impacting the global Python environment. You can use this same utility add additional utilities in an isolated environment. For example:

```bash
pipx install prospector
```

See the [pipx documentation](https://pipxproject.github.io/pipx/docs/) for additional information.

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

#### [Optional] Building your requirements into the container image

If your requirements rarely change, you can include the contents of `requirements.txt` in the container by adding the following to your `Dockerfile`:

```Dockerfile
COPY requirements.txt /tmp/pip-tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
    && rm -rf /tmp/pip-tmp
```

Since `requirements.txt` is likely in the folder you opened rather than the `.devcontainer` folder, be sure to include `"context": ".."` to `devcontainer.json`. This allows the Dockerfile to access everything in the opened folder instead of just the contents of the `.devcontainer` folder.

#### [Optional] Allowing the non-root vscode user to pip install globally without sudo

You can opt into using the `vscode` non-root user in the container by adding `"remoteUser": "vscode"` to `devcontainer.json`. However, by default, this you will need to use `sudo` to perform global pip installs.

```bash
sudo pip install <your-package-here>
```

Or stick with user installs:

```bash
pip install --user <your-package-here>
```

If you prefer, you can add the following to your `Dockerfile` to cause global installs to go into a different folder that the `vscode` user can write to.

```Dockerfile
ENV PIP_TARGET=/usr/local/pip-global
ENV PYTHONPATH=${PIP_TARGET}:${PYTHONPATH}
ENV PATH=${PIP_TARGET}/bin:${PATH}
RUN if ! cat /etc/group | grep -e "^pip-global:" > /dev/null 2>&1; then groupadd -r pip-global; fi \
    && usermod -a -G pip-global vscode \
    && umask 0002 && mkdir -p ${PIP_TARGET} \
    && chown :pip-global ${PIP_TARGET} \
    && ( [ ! -f "/etc/profile.d/00-restore-env.sh" ] || sed -i -e "s/export PATH=/export PATH=\/usr\/local\/pip-global:/" /etc/profile.d/00-restore-env.sh )
```

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/python-3-device-simulator-express` folder.
5. After the folder has opened in the container, `open the test-project/circuit.py` file.
6. Open the Command Palette (<kbd>Ctrl+Shift+P</kbd>) and select Device Simulator Express: Open Simulator command. 
7. You should see a prompt to select the circuit board. Select "Circuit Playground Express".
8. After the simulator has opened, click on the play (green button) and you should see the leds blinking.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE)
