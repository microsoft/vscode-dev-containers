# Anaconda (Python 3) & PostgreSQL

## Summary

*Develop Anaconda applications in Python3. Installs dependencies from your environment.yml file and the Python extension.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The [VS Code Python extension](https://marketplace.visualstudio.com/itemdetails?itemName=ms-python.python) team |
| *Categories* | Core, Languages |
| *Definition type* | Docker Compose |
| *Supported architecture(s)* | x86-64, aarch64/arm64 |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Python, Anaconda |

## Using this definition

This definition creates two containers, one for Anaconda/Python and one for PostgreSQL. VS Code will attach to the Anaconda container, and from within that container the PostgreSQL container will be available on **`localhost`** port 5432. The default database is named `postgres` with a user of `postgres` whose password is `postgres`, and if desired this may be changed in `docker-compose.yml`. Data is stored in a volume named `postgres-data`.

While the definition itself works unmodified, you can also directly reference pre-built versions by updating the `FROM` statement in your own `Dockerfile` to the following. An example `Dockerfile` is included in this repository.

- `mcr.microsoft.com/vscode/devcontainers/anaconda` (or `anaconda:3`)

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `mcr.microsoft.com/vscode/devcontainers/anaconda:0-3`
- `mcr.microsoft.com/vscode/devcontainers/anaconda:0.202-3`
- `mcr.microsoft.com/vscode/devcontainers/anaconda:0.202.0-3`

See the [python-3-anaconda history](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/python-3-anaconda/history) for information on the contents of each version and [here for a complete list of available tags](https://mcr.microsoft.com/v2/vscode/devcontainers/anaconda/tags/list).

You also can connect to PostgreSQL from an external tool when using VS Code by updating `.devcontainer/devcontainer.json` as follows:

```json
"forwardPorts": [ "5432" ]
```

### Adding another service

You can add other services to your `docker-compose.yml` file [as described in Docker's documentation](https://docs.docker.com/compose/compose-file/#service-configuration-reference). However, if you want anything running in this service to be available in the container on localhost, or want to forward the service locally, be sure to add this line to the service config:

```yaml
# Runs the service on the same network as the database container, allows "forwardPorts" in devcontainer.json function.
network_mode: service:[$SERVICE_NAME]
```

### Using Conda
This dev container and its associated anaconda image includes [the `conda` package manager](https://aka.ms/vscode-remote/conda/about). Additional packages installed using Conda will be downloaded from Anaconda or another repository if you configure one. To reconfigure Conda in this container to access an alternative repository, please see information on [configuring Conda channels here](https://aka.ms/vscode-remote/conda/channel-setup).

Access to the Anaconda repository is covered by the [Anaconda Terms of Service](https://aka.ms/vscode-remote/conda/terms), which may require some organizations to obtain a commercial license from Anaconda. **However**, when this dev container or its associated image is used with GitHub Codespaces or GitHub Actions, **all users are permitted** to use the Anaconda Repository through the service, including organizations normally required by Anaconda to obtain a paid license for commercial activities. Note that third-party packages may be licensed by their publishers in ways that impact your intellectual property, and are used at your own risk.

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

### Installing Node.js

Given JavaScript front-end web client code written for use in conjunction with a Python back-end often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/docker-compose.yml`.

```yaml
args:
  NODE_VERSION: "14" # Set to "none" to skip Node.js installation
```

#### Installing a different version of Python

As covered in the [user FAQ](https://docs.anaconda.com/anaconda/user-guide/faq) for Anaconda, you can install different versions of Python than the one in this image by running the following from a terminal:

```bash
conda install python=3.6
```

Or in a Dockerfile:

```Dockerfile
RUN conda install -y python=3.6
```

### [Optional] Adding the contents of environment.yml to the image

For convenience, this definition will automatically install dependencies from the `environment.yml` file in the parent folder when the container is built. You can change this behavior by altering this line in the `.devcontainer/Dockerfile`:

```Dockerfile
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml; fi \
    && rm -rf /tmp/conda-tmp
```

### Adding the definition to your folder

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
4. Select the `containers/python-3-anaconda-postgres` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to run the `plot.py` script in the project.
6. You should see `Open test-project/plot.png to see the result!` in the terminal and a `test-project/plot.png` file should be added to the folder after it runs with the plot result.
7. Next, open `test-project/plot.py` and press <kbd>ctrl/cmd</kbd>+<kbd>a</kbd> then <kbd>shift</kbd>+<kbd>enter</kbd>.
8. You should see the `matplotlib` output in the interactive window.
9. To run the `database.py` PostgreSQL connection script, navigate to the "Run and Debug" pane ( <kbd>ctrl/cmd</kbd>+<kbd>shift</kbd>+<kbd>D</kbd>) and select `Python database.py (Integrated Terminal)` from the dropdown and press <kbd>F5</kbd>.
10. You should see `DATABASE CONNECTED` and `One database in this database server is: postgres` in the terminal.
11. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## Running Jupyter notebooks

Use this container to run Jupyter notebooks.

1. Edit the `./.devcontainer/devcontainer.json` file and add `8888` in the `forwardPorts` array:

    ```json
    // Use 'forwardPorts' to make a list of ports inside the container available locally.
	"forwardPorts": [8888],
    ```
.
1. Edit the `./.devcontainer/devcontainer.json` file and add a `postStartCommand` command to start the Jupyter notebook web app after the container is created. Use nohup so it isn't killed when the command finishes. Logs will appear in `nohup.out`.

    ```json
	// Use 'postStartCommand' to run commands after the container is created.
	"postStartCommand": "nohup bash -c 'jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root &'",
    ```

1. View the terminal output to see the correct URL including the access token:

    ```bash
     http://127.0.0.1:8888/?token=1234567
    ```

1. Open the URL in a browser. You can edit and run code from the web browser.

1. If you have the [Jupyter extension](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter) installed, you can also edit and run code from VS Code. 

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE)
