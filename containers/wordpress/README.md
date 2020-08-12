# WordPress

## Summary

*Develop WordPress theme/plugins. Auto-install and configure WordPress environment with PHP-FPM, Nginx, and MariaDB to help you get up and running quickly.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [10up](https://github.com/10up), [Tung Du](https://github.com/dinhtungdu), [Jeffrey Paul](https://github.com/jeffpaul) |
| *Definition type* | Docker Compose |
| *Works in Codespaces* | No |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | PHP |

## Using this definition with an existing folder

Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. Decide whether you will use VS Code's copy of this definition or the latest-and-greatest copy of this definition from the repository.
   If you decide to use VS Code's copy:
      1. Start VS Code and open your project folder. The project folder must be the theme/plugin root folder.
      2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
      3. Select the WordPress definition.
   If you decide to use the latest-and-greatest copy from the repository:
      1. Clone this repository.
      2. Copy the contents of this folder in the cloned repository to the root of your project folder.
      3. Start VS Code and open your project folder.

4. You can adapt the contents of the `.devcontainer` folder in your project to meet your needs.

5. Press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

6. With the default definition, your WordPress site will be available at http://localhost:8080. The WordPress admin `username:password` is `admin:password` respectively.

## Notes

- This definition works for both plugin and theme, without any additional configuration.

- WP CLI is installed and registered as `wp` command.

- There is a `setup.log` file in the root of the WordPress folder inside the container (not theme/plugin root folder) to help you debug any errors that may occur.

- By default, the latest LTS version of node.js will be installed though you can change this version by changing `NODE_VERSION` in the `.devcontainer/createEnv.sh` file.

- By default, PHP 7.3 is installed. You can change the PHP version by changing `PHP_VERSION` in the `.devcontainer/createEnv.sh` file.

- This definition supports xDebug but it's disabled by default. To enable xDebug, uncomment the `felixfbecker.php-debug` extension in the `.devcontainer/devcontainer.json` file and change `ENABLE_XDEBUG` to `true` in `.devcontainer/createEnv.sh`. Please use `9001` as the port for the `launch.json` configuration.

  ```
  {
   "version": "0.2.0",
   "configurations": [
      {
         "name": "Listen for XDebug",
         "type": "php",
         "request": "launch",
         "port": 9001,
      },
   ]
  }
  ```

- Don't forget to rebuild the container for the above changes to take effect.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
