# Terraform Install Script

*Installs the Terraform CLI and optionally TFLint. Auto-detects latest version and installs needed dependencies.*

**Script status**: Stable

**OS support**: Debian 9+, Ubuntu 16.04+, and downstream distros.

**Maintainer:** The VS Code and GitHub Codespaces teams

## Syntax

```text
./terraform-debian.sh [Terraform version] [TFLint version] [Terragrunt version] [Terraform SHA256] [TFLint SHA256] [Terragrunt SHA256]
```

|Argument|Default|Description|
|--------|-------|-----------|
|Terraform version|`latest`| Version of the Terraform CLI to install. Use `latest` to install the latest released version. |
|TFLint version|`latest`| Version of TFLint to install. Use `none` to skip installing TFLint and `latest` to install the latest released version. |
|Terragrunt version|`latest`| Version of Terragrunt to install. Use `none` to skip installing Terragrunt and `latest` to install the latest released version. |
|Terraform SHA256|`automatic`| SHA256 checksum to use to verify the Terraform download. `automatic` will both acquire the checksum and do a signature verification of it. |
|TFLint SHA256|`automatic`| SHA256 checksum to use to verify the TFLint download. `automatic` will both acquire the checksum and do a signature verification of it. |
|Terragrunt SHA256|`automatic`| SHA256 checksum to use to verify the Terragrunt download. `automatic` will download the checksum. |



## Usage

Usage:

1. Add [`terraform-debian.sh`](../terraform-debian.sh) to `.devcontainer/library-scripts`

2. Add the following to your `.devcontainer/Dockerfile`:

    ```Dockerfile
    COPY library-scripts/github-debian.sh /tmp/library-scripts/
    RUN apt-get update && bash /tmp/library-scripts/terraform-debian.sh
    ```

That's it!
