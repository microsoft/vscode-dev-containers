# Ruby Install Script

*Installs Ruby, rvm, common Ruby utilities, and needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

## Syntax

```text
./ruby-debian.sh [Ruby version] [Non-root user] [Add rvm to rc files flag] [Install tools flag]
```

|Argument|Default|Description|
|--------|-------|-----------|
|Ruby version|`latest`| Version of Ruby to install. |
|Non-root user|`automatic`| Specifies a user in the container other than root that will use Ruby and rvm. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | `true` | A `true`/`false` flag that indicates whether sourcing the rvm script should be added to `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |
| Install tools flag | `true` | A `true`/`false` flag that indicates whether tools like `rake`, `ruby-debug-ide`, and `debase`` should be installed. |

## Usage

Usage:

1. Add [`ruby-debian.sh`](../ruby-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/ruby-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/ruby-debian.sh "${CARGO_HOME}" "${RUSTUP_HOME}"
    ```

That's it!
