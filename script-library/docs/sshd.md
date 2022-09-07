**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `sshd` Feature to [devcontainers/features/src/sshd](https://github.com/devcontainers/features/tree/main/src/sshd).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# SSHD Install Script

*Adds a SSH server into a container so that you can use an external terminal, sftp, or [SSHFS](#using-sshfs) to interact with it.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./sshd-debian.sh [SSH Port] [Non-root user] [Start SSHD now flag] [New password for user] [Fix environment flag]
```

Or as a feature:

```json
"features": {
    "sshd": "latest"
}
```

|Argument|Feature option|Default|Description|
|--------|--------------|-------|-----------|
| SSH port | | `2222`| Port to host SSH server on. `22` is frequently in use, so using a different port is recommended. |
| Non-root user | | `automatic`| Specifies a user in the container other than root that will use SSH. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
|Start SSHD now flag | | `false`| Flag (`true`/`false`) that specifies whether the SSH server should be started after the script runs.|
|New password for user| | `skip`| Sets a new password for the specified non-root user. A value of `skip` will skip this step. A value of `random` will generate a random password and print it out when the script finishes. |
|Fix environment flag| |`true`|Connections using the SSH daemon use "fresh" login shells. While Remote - Containers and Codespaces handle most environment variables automatically, Codespaces secrets require additional processing. |

## Usage

This script can be used as a feature, ad-hoc in an already running container, or in a Dockerfile. 

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "sshd": "latest"
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Usage when this script is already installed in an image 
The SSH script is included in the default Codespaces image (codespaces-linux) that is used in Codespaces when you do not have a custom `devcontainer.json`. It may also be in images you or your organization has created. Here's how to enable SSH in these cases. 

Usage:
1. Connect to your container or [codespace using VS Code (client)](https://docs.github.com/en/github/developing-online-with-codespaces/connecting-to-your-codespace-from-visual-studio-codeusing).

1. The first time you've started the container / codespace, you will want to set a password for your user. If running as a user other than root, and you have `sudo` installed:

    ```bash
    sudo passwd $(whoami)
    ```

    Or if you are running as root:

    ```bash
    passwd
    ```
 2. Open the ****Ports**** tab next to the Terminal tab, select Forward port and enter port `2222`. Take note of the **local address** port number if different than `2222`.

 3. Your container/codespace now has a running SSH server in it. Use a **local terminal** (or other tool) to connect to it using the command and password from step 2. e.g.

    ```bash
    ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null codespace@localhost
    ```

    ...where `codespace` above is the user you are running as in the container (e.g. `codespace`, `vscode`, `node`, or `root`) and `2222` after `-p` is the **local address port** from step 2.

    The “-o” arguments are optional, but will prevent you from getting warnings or errors about known hosts when you do this from multiple containers/codespaces.

  4. Next time you connect to your container/codespace, just repeat steps 2 and 3 and use the same password you set in step 1.

### Usage in a Dockerfile
You can add this script to your own Dockerfile as follows.

Usage:

1. Add [`sshd-debian.sh`](../sshd-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/sshd-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/sshd-debian.sh
    ENTRYPOINT ["/usr/local/share/ssh-init.sh"]
    CMD ["sleep", "infinity"]
    ```

    The `ENTRYPOINT` script can be chained with another script by adding it to the array after `ssh-init.sh`.

3. And the following to `.devcontainer/devcontainer.json`:

    ```json
    "forwardPorts": [2222],
    "overrideCommand": false
    ```

4. The first time you've started the container / codespace, you will want to set a password for your user (assuming you didn't set it using the script). If running as a user other than root, and you have `sudo` installed:

    ```bash
    sudo passwd $(whoami)
    ```

    Or if you are running as root:

    ```bash
    passwd
    ```

5. Connect to the container or [codespace using VS Code (client)](https://docs.github.com/en/github/developing-online-with-codespaces/connecting-to-your-codespace-from-visual-studio-code). You can now SSH into the container on port `2222`. For example, if you are in the container as the `vscode` user, run the following command in a **local terminal**:

    ```bash
    ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null vscode@localhost
    ```
    ...where `vscode` above is the user you are running as in the container (e.g. `codespace`, `vscode`, `node`, or `root`).

    The “-o” arguments are optional, but will prevent you from getting warnings or errors about known hosts when you do this from multiple containers/codespaces.

If you are unable to connect, it's possible SSH is available on a different local port because 2222 was busy. Open the ****Ports**** tab next to the Terminal tab, take note of the **local address port** for port 2222 in the container and update `-p 2222` to match.

### Ad-hoc Usage

If you already have a running container, you can use the script to spin up SSH inside it.

1. Connect to the container or [codespace using VS Code (client)](https://docs.github.com/en/github/developing-online-with-codespaces/connecting-to-your-codespace-from-visual-studio-code).

2. Open a terminal in VS Code and run the following if you're connected as a non-root user and `sudo` is installed:

    ```bash
    sudo bash -c "$(curl -sSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/sshd-debian.sh)" -- 2222 $(whoami) true random
    ```

    Or if running as root:

    ```bash
    bash -c "$(curl -sSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/sshd-debian.sh)" -- 2222 $(whoami) true random
    ```

3. Take note of the password that was generated and the SSH command.

4. Open the ****Ports**** tab next to the Terminal tab, select Forward port and enter port `2222`. Take note of the **local address port** number if different than `2222`.

5. Your container/codespace now has a running SSH server in it. Use a **local terminal** (or other tool) to connect to it using the command and password from step 2. e.g.

    ```bash
    ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vscode@localhost
    ```

    ...where `vscode` above is the user you are running as in the container (e.g. `codespace`, `vscode`, `node`, or `root`) and `2222` after `-p` is the **local address** port from step 4.

    The “-o” arguments are optional, but will prevent you from getting warnings or errors about known hosts when you do this from multiple containers/codespaces.

6. Next time you connect, you can spin up the SSH server again by running `/usr/local/share/sshd-init.sh` in a terminal in the container/codespace and using the same command / password.

### Using SSHFS

[SSHFS](https://en.wikipedia.org/wiki/SSHFS) allows you to mount a remote filesystem to your local machine with nothing but a SSH connection. Here's how to use it with a dev container.

1. Follow the steps in one of the previous sections to ensure you can connect to the dev container using the normal `ssh` client.

2. Install a SSHFS client.

    - **Windows:** Install [WinFsp](https://github.com/billziss-gh/winfsp/releases) and [SSHFS-Win](https://github.com/billziss-gh/sshfs-win/releases).
    - **macOS**: Use [Homebrew](https://brew.sh/) to install: `brew install macfuse gromgit/fuse/sshfs-mac`
    - **Linux:** Use your native package manager to install your distribution's copy of the sshfs package. e.g. `sudo apt-get update && sudo apt-get install sshfs`

3. Mount the remote filesystem.

    - **macOS / Linux:** Use the `sshfs` command to mount the remote filesystem. The arguments are similar to the normal `ssh` command but with a few additions. For example: 

        ```
        mkdir -p ~/sshfs/devcontainer
        sshfs "vscode@localhost:/workspaces" "$HOME/sshfs/devcontainer" -p 2222 -o follow_symlinks -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -C
        ```
        ...where `vscode` above is the user you are running as in the container (e.g. `codespace`, `vscode`, `node`, or `root`) and `2222` after the `-p` is the same local port you used in the `ssh` command in step 1.

    - **Windows:** Press Window+R and enter the following in the "Open" field in the Run dialog: 
    
        ```
        \\sshfs.r\vscode@localhost!2222\workspaces
        ```
        ...where `vscode` above is the user you are running as in the container (e.g. `codespace`, `vscode`, `node`, or `root`) and `2222` after the `!` is the same local port you used in the `ssh` command in step 1.

4. Your dev container's filesystem should now be available in the `~/sshfs/devcontainer` folder on macOS or Linux or in a new explorer window on Windows.
