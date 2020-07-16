# WordPress

## Summary

*Develop WordPress theme/plugins. Auto install and configure WordPress environment with PHP-FPM, Nginx and MariaDB to help you get up and running quickly.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Tung Du](https://github.com/dinhtungdu), [10up](https://github.com/10up) |
| *Definition type* | Docker Compose |
| *Works in Codespaces* | No |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | PHP |

## Using this definition with an existing folder

Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder. The project folder must be theme/plugin root folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the WordPress definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of this folder in the cloned repository to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.


## Notes

1. There is a `setup.log` file in the root of WordPress folder inside the container (not theme/plugin root folder) to help you debug if any error occurs.

2. By default, the latest LTS version of node.js will be installed, you can changed this version by update `NODE_VERSION` in `.devcontainer/createEnv.sh` file.

3. By default, PHP 7.3 is installed. Same as node.js, you can change the PHP version by changing `PHP_VERSION` in `.devcontainer/createEnv.sh` file.

4. This definition works for both plugin and theme, without any addition configuration.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).