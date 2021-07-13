# Desktop (Lightweight) Install Script

*Adds a lightweight [Fluxbox](http://fluxbox.org/) based desktop to the container that can be accessed using a VNC viewer or the web. UI-based commands executed from the built in VS code terminal will open on the desktop automatically.*

**Script status**: Preview

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

> **Note:** When using a VNC Viewer client, you may need to set the quality level to get high color since it can default to "low" with some clients.

## Syntax

```text
./desktop-lite-debian.sh [Non-root user] [VNC password] [Install noVNC flag]
```

|Argument|Default|Description|
|--------|-------|-----------|
|Non-root user|`automatic`| Specifies a user in the container other than root that will be using the desktop. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
|VNC password|`vscode`| Password for connecting to the desktop.|
|Install noVNC flag|`true`| Flag (`true`/`false`) that specifies whether to enable web access to the desktop using [noVNC](https://novnc.com/info.html).|

## Usage

1. Add [`desktop-lite-debian.sh`](../desktop-lite-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/desktop-lite-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/desktop-lite-debian.sh
    ENV DBUS_SESSION_BUS_ADDRESS="autolaunch:" DISPLAY=":1" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
    ENTRYPOINT ["/usr/local/etc/devcontainer-entrypoint.d/desktop-init.sh"]
    CMD ["sleep", "infinity"]
    ```

    If you have also run the [common script](./common.md), scripts in this repository wire into a common entrypoint you can use instead.

    ```Dockerfile
    ENTRYPOINT ["/usr/local/bin/devcontainer-entrypoint"]
    ```

    In either case, the `ENTRYPOINT` script can be chained with another script by adding it to the end of the array. 
    
    Finally, if you need to select a different locale, be sure to add it to `/etc/locale.gen` and run `locale-gen`.

3. And the following to `.devcontainer/devcontainer.json` if you are referencing an image or Dockerfile:

    ```json
    "runArgs": ["--init", "--security-opt", "seccomp=unconfined"],
    "forwardPorts": [6080, 5901],
    "overrideCommand": false
    ```

    Or if you are referencing a Docker Compose file, just include the `forwardPorts` property in `devcontainer.json` and add this to your `docker-compose.yml` instead:

    ```yaml
    your-service-here:
      init: true
      security_opt:
        - seccomp:unconfined
    ```

    The `runArgs` / Docker Compose setting allows the container to take advantage of an [init process](https://docs.docker.com/engine/reference/run/#specify-an-init-process) to handle application and process signals in a desktop environment.

4. Once you've started the container / codespace, you'll be able to use a browser on port **6080** from anywhere or connect a [VNC viewer](https://www.realvnc.com/en/connect/download/viewer/) to port **5901** when accessing the codespace from VS Code.

5. Default **password**: `vscode`

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
        && apt-get -y install /tmp/chrome.deb \
        && ALIASES="alias google-chrome='google-chrome --disable-dev-shm-usage'\nalias google-chrome-stable='google-chrome-stable --disable-dev-shm-usage'\n\alias x-www-browser='x-www-browser --disable-dev-shm-usage'\nalias gnome-www-browser='gnome-www-browser --disable-dev-shm-usage'" \
        && echo "${ALIASES}" >> tee -a /etc/bash.bashrc \
        && if type zsh > /dev/null 2>&1; then echo "${ALIASES}" >> /etc/zsh/zshrc; fi
    ```

2. Chrome sandbox support requires you set up and run as a non-root user. The [common script](common.md) can do this for you, or you [set one up yourself](https://aka.ms/vscode-remote/containers/non-root). Alternatively, you can start Chrome using `google-chrome --no-sandbox --disable-dev-shm-usage`

3. While Chrome should be aliased correctly with the instructions above, if you run into crashes, pass `--disable-dev-shm-usage` in as an argument when starting it: `google-chrome --disable-dev-shm-usage`

That's it!
