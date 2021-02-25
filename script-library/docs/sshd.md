# SSHD Install Script

*Adds a SSH server into a container so that you can use an external terminal, scp, sftp, or SSHFS to interact with it.*

**Script status**: Preview

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

## Syntax

```text
./sshd-debian.sh [SSH Port] [Non-root user] [Start SSHD now flag] [New password for user]
```

|Argument|Default|Description|
|--------|-------|-----------|
| SSH port |`2222`| Port to host SSH server on. `22` is frequently in use, so using a different port is recommended. |
| Non-root user |`automatic`| Specifies a user in the container other than root that will use SSH. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
|Start SSHD now flag |`false`| Flag (`true`/`false`) that specifies whether the SSH server should be started after the script runs.|
|New password for user|`skip`| Sets a new password for the specified non-root user. A value of `skip` will skip this step. A value of `random` will generate a random password and print it out when the script finishes. |

## Usage

This script can be used either ad-hoc in an already running container or in a Dockerfile. 

### Usage when this script is already installed in an image 
The SSH script is included in the default Codespaces image (codespaces-linux) that is used in Codespaces when you do not have a custom `devcontainer.json`. It may also be in images you or your organization has created. Here's how to enable SSH in these cases. 

Usage:
1. The first time you've started the codespace, you will want to set a password for your user. If running as a user other than root, and you have `sudo` installed:

    ```bash
    sudo passwd $(whoami)
    ```

    Or if you are running as root:

    ```bash
    passwd
    ```
 2. Open the ****Ports**** tab next to the Terminal tab, select Forward port and enter port `2222`.
 3. Your container/codespace now has a running SSH server in it. Use a **local terminal** (or other tool) to connect to it using the command and password from step 2. e.g.

    ```bash
    ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vscode@localhost
    ```

    The “-o” arguments are optional, but will prevent you from getting warnings or errors about known hosts when you do this from multiple containers/codespaces.

  4. Next time you connect, you can spin up the SSH server again by running `/usr/local/share/sshd-init.sh` in a terminal in the container/codespace and using the same command / password.

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

5. Connect to the container or [codespace using VS Code](https://docs.github.com/en/github/developing-online-with-codespaces/connecting-to-your-codespace-from-visual-studio-code). You can now SSH into the container on port `2222`. For example, if you are in the container as the `vscode` user, run the following command in a **local terminal**:

    ```bash
    ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vscode@localhost
    ```

    The “-o” arguments are optional, but will prevent you from getting warnings or errors about known hosts when you do this from multiple containers/codespaces.

### Ad-hoc Usage

If you already have a running container, you can use the script to spin up SSH inside it.

1. Connect to the container or [codespace using VS Code](https://docs.github.com/en/github/developing-online-with-codespaces/connecting-to-your-codespace-from-visual-studio-code).

2. Open a terminal in VS Code and run the following if you're connected as a non-root user and `sudo` is installed:

    ```bash
    sudo bash -c "$(curl -sSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/sshd-debian.sh)" -- 2222 $(whoami) true random
    ```

    Or if running as root:

    ```bash
    bash -c "$(curl -sSL https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/sshd-debian.sh)" -- 2222 $(whoami) true random
    ```

3. Take note of the password that was generated and the SSH command.

4. Open the ****Ports**** tab next to the Terminal tab, select Forward port and enter port `2222`.

5. Your container/codespace now has a running SSH server in it. Use a **local terminal** (or other tool) to connect to it using the command and password from step 2. e.g.

    ```bash
    ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vscode@localhost
    ```

    The “-o” arguments are optional, but will prevent you from getting warnings or errors about known hosts when you do this from multiple containers/codespaces.

6. Next time you connect, you can spin up the SSH server again by running `/usr/local/share/sshd-init.sh` in a terminal in the container/codespace and using the same command / password.

That's it!
