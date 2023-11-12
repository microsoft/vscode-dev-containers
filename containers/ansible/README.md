# Ansible

## Summary

*Develop Ansible automations and collections/roles*

| Metadata | Value |
| -------- | ----- |
| *Contributors* | [Fischbacher Markus](https://gitlab.com/rockaut) |
| *Categories* | Community, Ansible |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container Host OS Support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Python |

## Using this definition

The environment is heavily based on the [Python 3 devcontainers](https://github.com/rockaut/vscode-dev-containers/tree/main/containers/python-3) and slightly modified to automate the Ansible installs. So maybe also look at those too.

### Included

The container as such already includes pip and wheel for easier installation of ansible things.
It also creates the basic directory requirements for ansible itself and also for collection/role creation.
You may just mount your workspace folder (see devcontainer.json).

The devcontainer also enables redhat.ansible plugin (see devcontainer.json).

### Configuration

While the definition itself works unmodified, you can select the version of Python the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
// Or you can use 3.7-bullseye or 3.7-buster if you want to pin to an OS version
"args": { "VARIANT": "3.10-bullseye" }
```

#### [Optional] Building your requirements into the container image

If your requirements rarely change, you can include the contents of `requirements.txt` in the container by adding the following to your `Dockerfile`:

```Dockerfile
COPY requirements.txt /tmp/pip-tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
    && rm -rf /tmp/pip-tmp
```

Since `requirements.txt` is likely in the folder you opened rather than the `.devcontainer` folder, be sure to include `"context": ".."` to `devcontainer.json`. This allows the Dockerfile to access everything in the opened folder instead of just the contents of the `.devcontainer` folder.

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
   4. Update `.devcontainer/devcontainer.json`

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE)

