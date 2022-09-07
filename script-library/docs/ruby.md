**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `ruby` Feature to [devcontainers/features/src/ruby](https://github.com/devcontainers/features/tree/main/src/ruby).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Ruby Install Script

*Installs Ruby, rvm, rbenv, common Ruby utilities, and needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./ruby-debian.sh [Ruby version] [Non-root user] [Add rvm to rc files flag] [Install tools flag]
```

Or as a feature:

```json
"features": {
    "ruby": "latest"
}
```

|Argument|Feature option|Default|Description|
|--------|--------------|-------|-----------|
|Ruby version| `version` |`latest`| Version of Ruby to install. A value of `none` will skip this step and just install rvm, rbenv, and tools. |
|Non-root user| |`automatic`| Specifies a user in the container other than root that will use Ruby, rvm, and/or rbenv. A value of `automatic` will cause the script to check for a user called `vscode`, then `node`, `codespace`, and finally a user with a UID of `1000` before falling back to `root`. |
| Add to rc files flag | |`true` | A `true`/`false` flag that indicates whether sourcing the rvm script should be added to `/etc/bash.bashrc` and `/etc/zsh/zshrc`. |
| Install tools flag | |`true` | A `true`/`false` flag that indicates whether tools like `rake`, `ruby-debug-ide`, and `debase` should be installed. |

## Usage

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "ruby": "latest"
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

Usage:

1. Add [`ruby-debian.sh`](../ruby-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    ENV GEM_PATH="/usr/local/rvm/gems/default:/usr/local/rvm/gems/default@global" \
        GEM_HOME="/usr/local/rvm/gems/default" \
        MY_RUBY_HOME="/usr/local/rvm/rubies/default" \
        PATH="/usr/local/rvm/rubies/default/bin:/usr/local/rvm/gems/default@global/bin:/usr/local/rvm/rubies/default/bin:/usr/local/rvm/bin:${PATH}"
    COPY library-scripts/ruby-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/ruby-debian.sh
    ```

The `ENV` parameters are technically optional, but allow the default `rvm` installed version of Ruby to be used in non-interactive terminals and shell scripts.

That's it!
