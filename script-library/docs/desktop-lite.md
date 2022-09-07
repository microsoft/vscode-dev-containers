**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `desktop-lite` Feature to [devcontainers/features/src/desktop-lite](https://github.com/devcontainers/features/tree/main/src/desktop-lite).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Desktop (Lightweight) Install Script

*Adds a lightweight [Fluxbox](http://fluxbox.org/) based desktop to the container that can be accessed using a VNC viewer or the web. GUI-based commands executed from the built-in VS code terminal will open on the desktop automatically.*

**Script status**: Preview

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

> **Note:** When using a VNC Viewer client, you may need to set the quality level to get high color since it can default to "low" with some clients.

## Syntax

```text
./desktop-lite-debian.sh [Non-root user] [Desktop password] [Install web client flag] [VNC port] [Web port]
```

Or as a feature:

```json
"features": {
    "desktop-lite": {
        "password": "vscode",
        "webPort": "6080",
        "vncPort": "5901"
    }
}
```

|Argument| Feature option |Default|Description|
|--------|----------------|-------|-----------|
|Non-root user| | `automatic`| Specifies a user in the container other than root that will be using the desktop. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
|Desktop password| `password` | `vscode`| Password for connecting to the desktop.|
|Install web client flag| | `true`| Flag (`true`/`false`) that specifies whether to enable web access to the desktop using [noVNC](https://novnc.com/info.html).|
|VNC Port| `vncPort` | `5901`| Port to host a VNC server that you can use to connect to the desktop using a VNC Viewer.|
|Web port | `webPort` | `6080`| Port to host the [noVNC](https://novnc.com/info.html) web client that you can use to connect to the desktop from a browser.|

## Usage

### Feature use

You can use this script for your primary dev container by adding it to the `features` property in `devcontainer.json`. 

```json
"features": {
    "desktop-lite": {
        "password": "vscode",
        "webPort": "6080",
        "vncPort": "5901"
    }
}
```

If you run into applications crashing, you may need to increase the size of the shared memory space. For example, this will bump it up to 1 GB in `devcontainer.json` when you are referencing an image or Dockerfile:

```json
"runArgs": ["--shm-size=1g"]
```

Or when using Docker Compose:

```yaml
services:
  your-service-here:
    # ...
    shm_size: '1gb'
    # ...
```

**[Optional]** You may also want to enable the [tini init process](https://docs.docker.com/engine/reference/run/#specify-an-init-process) to handle signals and clean up [Zombie processes](https://en.wikipedia.org/wiki/Zombie_process) if you do not have an alternative set up. To enable it, add the following to `devcontainer.json` if you are referencing an image or Dockerfile:

```json
"runArgs": ["--init"]
```

Or when using Docker Compose:

```yaml
services:
  your-service-here:
    # ...
    init: true
    # ...
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

1. Add [`desktop-lite-debian.sh`](../desktop-lite-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/desktop-lite-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/desktop-lite-debian.sh
    ENV DBUS_SESSION_BUS_ADDRESS="autolaunch:" \
        VNC_RESOLUTION="1440x768x16" \
        VNC_DPI="96" \
        VNC_PORT="5901" \
        NOVNC_PORT="6080" \
        DISPLAY=":1" \
        LANG="en_US.UTF-8" \
        LANGUAGE="en_US.UTF-8"
    ENTRYPOINT ["/usr/local/share/desktop-init.sh"]
    CMD ["sleep", "infinity"]
    ```

    The `ENTRYPOINT` script can be chained with another script by adding it to the array after `desktop-init.sh`.
    If you need to select a different locale, be sure to add it to `/etc/locale.gen` and run `locale-gen`.

3. And the following to `.devcontainer/devcontainer.json` if you are referencing an image or Dockerfile:

    ```json
    "runArgs": ["--init"],
    "forwardPorts": [6080, 5901],
    "overrideCommand": false
    ```

    Or if you are referencing a Docker Compose file, just include the `forwardPorts` property in `devcontainer.json` and add this to your `docker-compose.yml` instead:

    ```yaml
    your-service-here:
      init: true
    ```

    The `runArgs` / Docker Compose setting allows the container to take advantage of an [init process](https://docs.docker.com/engine/reference/run/#specify-an-init-process) to handle application and process signals in a desktop environment. However, this is optional.

4. [Optional] If you run into applications crashing, you may need to increase the size of the shared memory space. For example, this will bump it up to 1 GB in `devcontainer.json`:

    ```json
    "runArgs": ["--init", "--shm-size=1g"]
    ```

    Or using Docker Compose:

    ```yaml
    services:
      your-service-here:
        # ...
        init: true
        shm_size: '1gb'
        # ...
    ```

5. Once you've started the container / codespace, you'll be able to use a browser on port **6080** from anywhere or connect a [VNC viewer](https://www.realvnc.com/en/connect/download/viewer/) to port **5901** when accessing the codespace from VS Code.

6. Default **password**: `vscode`

The window manager is installed is [Fluxbox](http://fluxbox.org/). **Right-click** to see the application menu. In addition, any UI-based commands you execute in the VS Code integrated terminal will automatically appear on the desktop.

### Customizing Fluxbox

You can customize the contents of the application menu by editing `~/.fluxbox/menu` (just type `code ~/.fluxbox/menu` or `code-insiders ~/.fluxbox/menu` to edit). See the [menu documentation](http://www.fluxbox.org/help/man-fluxbox-menu.php) for format details.

More information on additional customization can be found in Fluxbox's [help](http://www.fluxbox.org/help/) and [general](http://fluxbox.sourceforge.net/docbook/en/html/book1.html) documentation.

## Installing a browser

If you need a browser, you can install **Firefox ESR** by adding the following to `.devcontainer/Dockerfile`:

```Dockerfile
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y firefox-esr
```

If you want the full version of **Google Chrome** in the desktop:

1. Add the following to `.devcontainer/Dockerfile`

    ```Dockerfile
    RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
        && curl -sSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb \
        && apt-get -y install /tmp/chrome.deb
    ```

2. Chrome sandbox support requires you set up and run as a non-root user. The [`debian-common.sh`](common.md) script can do this for you, or you [set one up yourself](https://aka.ms/vscode-remote/containers/non-root). Alternatively, you can start Chrome using `google-chrome --no-sandbox`

That's it!
