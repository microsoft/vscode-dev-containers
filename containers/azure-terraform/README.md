# Azure Terraform

## Summary

[Terraform](https://www.terraform.io/) is an open-source tool that provides the ability to build, change, and version infrastructure as code using declarative configuration files with HashiCorp Configuration Language (HCL).

This recipe allows you to get going quickly with Terraform in Azure. Includes Terraform, the Azure CLI, the Docker CLI (for testing locally), Node.js for Cloud Shell, and related extensions and dependencies.

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Carlos Mendible](https://github.com/cmendible), [Charles Zipp](https://github.com/charleszipp), [Lila Molyva](https://github.com/norelina), [Tas Devani](https://github.com/tasdevani21)  |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Azure, Terraform |

## Using this definition with an existing folder

While technically optional, this definition includes the Azure Terraform extension which requires a few pre-requisites:

- [Azure Subscription](https://azure.microsoft.com): A current Azure subscription or a [free trial](https://azure.microsoft.com/en-us/free/) account needed.

You can also choose the specific version of Terraform installed by updating the following line in `.devcontainer/devcontainer.json`:

```Dockerfile
"arg": {
   "TERRAFORM_VERSION": "0.13.0"
   "TFLINT_VERSION": "0.19.0",
   "INSTALL_AZURE_CLI": "true",
   "INSTALL_DOCKER": "true",
   "INSTALL_NODE": "true"
}
```

If you plan to use the Azure Cloud Shell for all of your Terraform operations, you can set `"INSTALL_DOCKER": "false"`. Conversely, if you do not plan to use Cloud Shell, you can set `"INSTALL_DOCKER": "false"`. By default, both are installed so you can decide later.

Beyond `git`, this `Dockerfile` includes `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

### Adding the definition to your project

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

5. Open the Command Palette with `Ctrl/CMD+Shift+P` or press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the Definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. Follow steps 1-4 from the above [section](#adding-the-definition-to-your-project).
2. Fill in the values for the environment variables in the [`.devcontainer/devcontainer.env` file](https://code.visualstudio.com/docs/remote/containers-advanced#_option-2-use-an-env-file)
   - This file allows customization of the environment variables and the values needed for the terraform tasks.

3. Open the Command Palette with `Ctrl/CMD+Shift+P` or press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

4. Execute the basic Terraform configuration that will provision a new Azure Resource Group. VS Code tasks have been configured to run commonly used commands. These can be accessed via `Ctrl/CMD+Shift+P` > `Tasks: Run Tasks`.

   ![Run Terraform Tasks](test-project/assets/Terraform_tasks.png)

A more detailed explanation of the tasks can be found in the next [section](#running-the-tasks).

## Running the Tasks

Once the environment settings are configured with the `.devcontainer/devcontainer.env`, you can begin executing terraform commands. VS Code tasks have been configured to run each of the commonly used terraform commands.

- `az login`: login to Azure and set your default subscription
- `terraform create backend`: create (if it does not exists) a remote azurerm backend (storage account)
- `terraform init`: installs plugins and connect to terraform remote backend
- `terraform format`: fix formatting issues
- `terraform lint`: fix linting issues
- `terraform validate`: check templates for syntax errors
- `terraform plan`: report what would be done with apply without actually deploying any resources
- `terraform apply`: deploy the terraform templates
- `terraform destroy`: destroy resources deployed with the templates

## References

- [Terraform Overview](https://www.terraform.io/intro/index.html)
- [Terraform Tutorials](https://learn.hashicorp.com/terraform?utm_source=terraform_io)
- [Terraform with Azure](https://docs.microsoft.com/en-us/azure/terraform/terraform-overview).
- [Terraform Extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
