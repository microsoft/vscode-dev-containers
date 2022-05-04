# Python Package Install Script

*Installs a Python package.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer**: GitHub Codespaces team

## Syntax

```text
./python-package-debian.sh PACKAGE [VERSION] [PYTHON_BINARY] [USERNAME]
```

## Usage

### Script use

1. Add [`python-package-debian.sh`](../python-package-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/python-package-debian.sh /tmp/library-scripts/
    RUN bash /tmp/library-scripts/python-package-debian.sh PACKAGE
    ```

That's it!
