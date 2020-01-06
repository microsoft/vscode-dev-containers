# Azure Terraform 0.12

## Summary

*Get going quickly with Terraform in Azure. Includes Terraform, the Azure CLI, the Docker CLI (for testing locally), Node.js for Cloud Shell, and related extensions and dependencies.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Carlos Mendible](https://github.com/cmendible) |
| *Definition type* | Dockerfile |
| *Languages, platforms* | Terraform |

## Using this definition with an existing folder

While technically optional, this definition includes the Azure Terraform extension which requires an Azure account to use. You can create a [free trial account here](https://azure.microsoft.com/en-us/free/) and find out more about using [Teraform with Azure here](https://docs.microsoft.com/en-us/azure/terraform/terraform-overview).  If you plan to use the Azure Cloud Shell for all of your Terraform operations, you can comment out the installation of the Docker CLI in `.devcontainer/Dockerfile`. Conversely, if you do not plan to use Cloud Shell, you can comment out the installation of Node.js. The definition has been setup so you can do either as it makes sense.

You can also choose the specific version of Terraform installed by updating the following line in `.devcontainer/Dockerfile`:

```Dockerfile
ARG TERRAFORM_VERSION=0.12.16
```

Next, follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Azure Terraform definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/azure-terraform/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
