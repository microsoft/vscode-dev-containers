**IMPORTANT NOTE: We're starting to migrate contents of this repo to the [devcontainers org](https://github.com/devcontainers), as part of the work on the [open dev container specification](https://containers.dev).**

**We've currently migrated the `terraform` Feature to [devcontainers/features/src/terraform](https://github.com/devcontainers/features/tree/main/src/terraform).**

**For more details, you can review the [announcement issue](https://github.com/microsoft/vscode-dev-containers/issues/1589).**

# Terraform Install Script

*Installs the Terraform CLI and optionally TFLint and Terragrunt. Auto-detects latest version and installs needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 18.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./terraform-debian.sh [Terraform version] [TFLint version] [Terragrunt version] [Terraform SHA256] [TFLint SHA256] [Terragrunt SHA256]
```

Or as a feature:

```json
"features": {
    "terraform": {
        "version": "latest",
        "tflint": "latest",
        "terragrunt": "latest"
    }
}
```

|Argument|Feature option|Default|Description|
|--------|--------------|-------|-----------|
|Terraform version|`version`|`latest`| Version of the Terraform CLI to install. Use `latest` to install the latest released version. |
|TFLint version| `tflint` | `latest`| Version of TFLint to install. Use `none` to skip installing TFLint and `latest` to install the latest released version. |
|Terragrunt version|`terragrunt` | `latest`| Version of Terragrunt to install. Use `none` to skip installing Terragrunt and `latest` to install the latest released version. |
|Terraform SHA256| |`automatic`| SHA256 checksum to use to verify the Terraform download. `automatic` will both acquire the checksum and do a signature verification of it. |
|TFLint SHA256| | `automatic`| SHA256 checksum to use to verify the TFLint download. `automatic` will both acquire the checksum and do a signature verification of it. |
|Terragrunt SHA256| | `automatic`| SHA256 checksum to use to verify the Terragrunt download. `automatic` will download the checksum. |

## Usage

### Feature use

To install these capabilities in your primary dev container, reference it in `devcontainer.json` as follows:

```json
"features": {
    "terraform": {
        "version": "latest",
        "tflint": "latest",
        "terragrunt": "latest"
    }
}
```

If you have already built your development container, run the **Rebuild Container** command from the command palette (<kbd>Ctrl/Cmd</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> or <kbd>F1</kbd>) to pick up the change.

### Script use

Usage:

1. Add [`terraform-debian.sh`](../terraform-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/terraform-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/terraform-debian.sh
    ```

That's it!
