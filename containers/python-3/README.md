# Python 3

## Summary

*Develop Python 3 applications.*

| Metadata | Value |
|----------|-------|
| *Contributors* | The [VS Code Python extension](https://marketplace.visualstudio.com/itemdetails?itemName=ms-python.python) team |
| *Categories* | Core, Languages |
| *Definition type* | Dockerfile |
| *Published image* | mcr.microsoft.com/vscode/devcontainers/python |
| *Available image variants* | 3, 3.6, 3.7, 3.8, 3.9 ([full list](https://mcr.microsoft.com/v2/vscode/devcontainers/python/tags/list)) |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container Host OS Support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Python |

See **[history](history)** for information on the contents of published images.

## Using this definition

### Configuration

While the definition itself works unmodified, you can select the version of Python the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "3.7" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own `Dockerfile` with one of the following:

- `mcr.microsoft.com/vscode/devcontainers/python:3` (latest)
- `mcr.microsoft.com/vscode/devcontainers/python:3.6`
- `mcr.microsoft.com/vscode/devcontainers/python:3.7`
- `mcr.microsoft.com/vscode/devcontainers/python:3.8`
- `mcr.microsoft.com/vscode/devcontainers/python:3.9`

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `mcr.microsoft.com/vscode/devcontainers/python:0-3.9`
- `mcr.microsoft.com/vscode/devcontainers/python:0.201-3.9`
- `mcr.microsoft.com/vscode/devcontainers/python:0.201.5-3.9`

See [history](history) for information on the contents of each version and [here for a complete list of available tags](https://mcr.microsoft.com/v2/vscode/devcontainers/python/tags/list).

Alternatively, you can use the contents of `base.Dockerfile` to fully customize the your container's contents or build for a container architecture the image does not support.

Beyond Python and `git`, this image / `Dockerfile` includes a number of Python tools, `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

### Installing Node.js

Given JavaScript front-end web client code written for use in conjunction with a Python back-end often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.

```jsonc
"args": {
    "VARIANT": "3",
    "NODE_VERSION": "10" // Set to "none" to skip Node.js installation
}
```

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

#### [Optional] Installing multiple versions of Python in the same image

If you would prefer to have multiple Python versions in your container, use `base.Dockerfile` and update `FROM` statement:

```Dockerfile
FROM ubuntu:bionic
ARG PYTHON_PACKAGES="python3.5 python3.6 python3.7 python3.8 python3 python3-pip python3-venv"
RUN apt-get update && apt-get install --no-install-recommends -yq software-properties-common \
     && add-apt-repository ppa:deadsnakes/ppa && apt-get update \
     && apt-get install -yq --no-install-recommends ${PYTHON_PACKAGES} \
     && pip3 install --no-cache-dir --upgrade pip setuptools wheel
```

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. To use the pre-built image:
   1. Start VS Code and open your project folder or connect to a codespace.
   2. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.
   4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

3. To build a custom version of the image instead:
   1. Clone this repository locally.
   2. Start VS Code and open your project folder or connect to a codespace.
   3. Use your local operating system's file explorer to drag-and-drop the locally cloned copy of the `.devcontainer` folder for this definition into the VS Code file explorer for your opened project or codespace.
   4. Update `.devcontainer/devcontainer.json` to reference `"dockerfile": "base.Dockerfile"`.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/python-3` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "Hello, remote world!" in a terminal window after the program executes.
7. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE)

