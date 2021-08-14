# docfx Install Script

> **Note:** This is a community contributed and maintained script.

_Adds [docfx](https://github.com/dotnet/docfx) to a container._

**Script status**: Draft

**OS support**: Debian 9+, Ubuntu 16.04+.

**Maintainer:** [@JamieMagee](https://github.com/JamieMagee)

## Syntax

```text
./docfx-debian.sh
```

| Argument | Default | Description |
| -------- | ------- | ----------- |
|Non-root user|`automatic`| Specifies a user in the container other than root that will use docfx. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |

## Usage

Usage:

1. Add [`docfx-debian.sh`](../docfx-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

   ```Dockerfile
   COPY library-scripts/docfx-debian.sh /tmp/library-scripts/
   RUN apt-get update && bash /tmp/library-scripts/docfx-debian.sh
   ```
