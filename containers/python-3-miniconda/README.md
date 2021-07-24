# Miniconda (Python 3)

## Summary

*Develop Miniconda applications in Python 3. Installs dependencies from your environment.yml file and the Python extension.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The [VS Code Python extension](https://marketplace.visualstudio.com/itemdetails?itemName=ms-python.python) team |
| *Categories* | Languages |
| *Definition type* | Dockerfile |
| *Published image* | mcr.microsoft.com/vscode/devcontainers/miniconda:3 |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Python, Anaconda, Miniconda |

See **[history](history)** for information on the contents of published images.

## Using this definition

### Configuration

While the definition itself works unmodified, you can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own `Dockerfile` to the following. An example `Dockerfile` is included in this repository.

- `mcr.microsoft.com/vscode/devcontainers/minconda` (or `minconda:3`)

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `mcr.microsoft.com/vscode/devcontainers/miniconda:0-3`
- `mcr.microsoft.com/vscode/devcontainers/miniconda:0.201-3`
- `mcr.microsoft.com/vscode/devcontainers/miniconda:0.201.4-3`

See [history](history) for information on the contents of each version and [here for a complete list of available tags](https://mcr.microsoft.com/v2/vscode/devcontainers/miniconda/tags/list).

Alternatively, you can use the contents of `base.Dockerfile` to fully customize your container's contents or to build it for a container host architecture not supported by the image.

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

#### Installing Node.js

Given JavaScript front-end web client code written for use in conjunction with a Python back-end often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.

```jsonc
"args": {
    "NODE_VERSION": "14" // Set to "none" to skip Node.js installation
}
```

#### Installing or updating Python utilities

This container installs all Python development utilities using [pipx](https://pipxproject.github.io/pipx/) to avoid impacting the global Python environment. You can use this same utility add additional utilities in an isolated environment. For example:

```bash
pipx install prospector
```

Note that if you change the version of Python from the default, you'll need to run a few commands to update the utilities and `pipx`. More on that next.

#### Installing a different version of Python

As covered in the [user FAQ](https://docs.anaconda.com/anaconda/user-guide/faq) for Anaconda, you can install different versions of Python than the one in this image by running the following from a terminal:

```bash
conda install python=3.6
pip install --no-cache-dir pipx
pipx uninstall pipx
pipx reinstall-all
```

Or in a Dockerfile:

```Dockerfile
RUN conda install -y python=3.6 \
    && pip install --no-cache-dir pipx \
    && pipx uninstall pipx \
    && pipx reinstall-all
```

See the [pipx documentation](https://pipxproject.github.io/pipx/docs/) for additional information.

### [Optional] Adding the contents of environment.yml to the image

For convenience, this definition will automatically install dependencies from the `environment.yml` file in the parent folder when the container is built. You can change this behavior by altering this line in the `.devcontainer/Dockerfile`:

```Dockerfile
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml; fi \
    && rm -rf /tmp/conda-tmp
```

### Adding the definition to your folder

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
4. Select the `containers/python-3-miniconda` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. A `test-project/plot.png` file should be added to the folder after it runs with the plot result.
7. Next, open `test-project/hello.py` and press <kbd>ctrl/cmd</kbd>+<kbd>a</kbd> then <kbd>shift</kbd>+<kbd>enter</kbd>.
8. You should see the `matplotlib` output in the interactive window.
9. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE)
