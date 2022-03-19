# JupyterLab Install Script

*Installs JupyterLab.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer**: GitHub Codespaces team

## Syntax

```text
./jupyterlab-debian.sh
```

Or as a feature:

```json
"features": {
  "jupyterlab": {
    "version": "latest"
  }
}
```

## Usage

### Feature use

To install this feature in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
  "jupyterlab": {
    "version": "latest"
  }
}
```

If you have already built your development container, run the **Rebuild Container** command from the command
palette (<kdb>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

You must have Python already installed in order to use this feature.

### Script use

1. Add [`jupyterlab-debian.sh`](../jupyterlab-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/jupyterlab-debian.sh /tmp/library-scripts/
    RUN bash /tmp/library-scripts/jupyterlab-debian.sh
    ```

That's it!
