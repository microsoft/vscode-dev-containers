# Python 3 & PostgreSQL

## Summary

*Develop applications with Python 3 and PostgreSQL. Includes a Python application container and PostgreSQL server.*

| Metadata | Value |
|----------|-------|
| *Contributors* | The [VS Code Python extension](https://marketplace.visualstudio.com/itemdetails?itemName=ms-python.python) team |
| *Definition type* | Docker Compose |
| *Published image* | mcr.microsoft.com/vscode/devcontainers/python:3 |
| *Available image variants* |  mcr.microsoft.com/vscode/devcontainers/python:3.8 <br />  mcr.microsoft.com/vscode/devcontainers/python:3.7<br /> mcr.microsoft.com/vscode/devcontainers/python:3.6 |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Python |

## Using this definition with an existing folder

### Configuration

While the definition itself works unmodified, you can select the version of Python the container uses by updating the `VARIANT` arg in the included `.devcontainer/docker-compose.yml` (and rebuilding if you've already created the container).

```yaml
args:
  VARIANT": 3.7
```

This allows you to pick from one of the following pre-built images:

- `mcr.microsoft.com/vscode/devcontainers/python:3` (latest)
- `mcr.microsoft.com/vscode/devcontainers/python:3.6`
- `mcr.microsoft.com/vscode/devcontainers/python:3.7`
- `mcr.microsoft.com/vscode/devcontainers/python:3.8`

Alternatively, you can replace `.devcontainer/Dockerfile` in this definition with [`base.Dockerfile` from the Python 3 definition](../python-3/.devcontainer/base.Dockerfile) to fully customize your environment.

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

The `ports` property in `docker-compose.yml` [publishes](https://docs.docker.com/config/containers/container-networking/#published-ports) rather than forwards the port, so applications need to listen to `*` or `0.0.0.0` for the application to be accessible externally. This conflicts with the defaults of some Python frameworks, but fortunately the `forwardPorts` property does not have this limitation.

If you've already opened your folder in a container, rebuild the container using the **Remote-Containers: Rebuild Container** command from the Command Palette (<kbd>F1</kbd>) so the settings take effect.

#### [Optional] Building your requirements into the container image

If your requirements rarely change, you can include the contents of `requirements.txt` in the container by adding the following to your `Dockerfile`:

```Dockerfile
COPY requirements.txt /tmp/pip-tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
    && rm -rf /tmp/pip-tmp
```

Since `requirements.txt` is likely in the folder you opened rather than the `.devcontainer` folder, be sure to include `context: ..` under `build` in `docker-compose.yml`. This allows the Dockerfile to access everything in the opened folder instead of just the contents of the `.devcontainer` folder.

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
RUN mkdir -p ${PIP_TARGET} \
    && chown vscode:root ${PIP_TARGET} \
    && export SNIPPET="if [ \"\$(stat -c '%U' ${PIP_TARGET})\" != \"vscode\" ]; then chown -R vscode:root ${PIP_TARGET}; fi" \
    && echo "$SNIPPET" | tee -a /root/.bashrc >> /home/vscode/.bashrc \
    && echo "$SNIPPET" | tee -a /root/.zshrc >> /home/vscode/.zshrc
```

### Adding the definition to your folder

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Python 3 & PostgreSQL definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/python-3-postgres/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the *only* the contents of the `.devcontainer` folder in your project can be adapted to meet your needs. Ignore other files and folders.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/python-3-postgres` folder.
5. After the folder has opened in the container, use <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>`</kbd> to open a terminal and run the following commands to initialize the database and create a super user:
    ```bash
    cd test-project
    pip install --user -r requirements.txt
    python manage.py migrate
    python manage.py createsuperuser
    ```
6. Next, press <kbd>F5</kbd> to start the project.
7. Once the project is running, press <kbd>F1</kbd> and select **Remote-Containers: Forward Port...**
8. Select port 5000 and click the "Open Browser" button in the notification that appears.
9. You should see a page with a message indicating the install was successful. You can also go to `http://localhost:<port>/admin` and sign in.
10. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE)
