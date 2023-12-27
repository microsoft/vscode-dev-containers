# HashiStack 

## Summary

*Simple container with Nomad, Consul, and Vault*

| Metadata               | Value                                                        |
| ---------------------- | ------------------------------------------------------------ |
| *Contributors*         | The VS Code Team, [@thoward27](https://github.com/thoward27) |
| *Definition type*      | Dockerfile                                                   |
| *Published image*      | TODO                                                         |
| *Languages, platforms* | Any                                                          |

## Using this definition with an existing folder

This definition does not require any special steps to use. Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Ubuntu 18.04 & Git definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/ubuntu-18.04-git/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/ubuntu-18.04-git` folder.
5. Press <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>\`</kbd> and type the following command to verify installation: `apt-get update && apt-get install -y lsb-release && git --version && lsb_release -a`
6. After lsb_release installs, you should see the Git version and details about the version of Linux in the container.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE)
