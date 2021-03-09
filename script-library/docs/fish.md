# fish Install Script

*Adds [fish shell](https://github.com/fish-shell/fish-shell) to a container.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+.

## Syntax

```text
./fish-debian.sh [Install Fisher flag] [Non-root user]
```

|Argument|Default|Description|
|--------|-------|-----------|
| Install Fisher flag | `true` | A `true`/`false` flag that indicates whether to install [Fisher plugin manager](https://github.com/jorgebucaran/fisher). |
|Non-root user|`automatic`| Specifies a user in the container other than root that will use fish shell. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |

## Usage

Usage:

1. Add [`fish-debian.sh`](../fish-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/fish-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/fish-debian.sh
    ```

That's it!
