# PHP 7 & MariaDB

## Summary

Develop PHP 7 based applications with MariaDB (MySQL Compatible).  Includes necessary extensions and tools for both PHP and MariaDB.
| Metadata | Value |  
|----------|-------|
| *Contributors* | Richard Morrill [github.com/ThoolooExpress](https://github.com/ThoolooExpress) |
| *Definition type* | Docker Compose |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | PHP, MariaDB (MySQL Compatible) |

## Description

This definition creates two containers, one for PHP and one for MariaDB.  Code will attach to the PHP container, and from within that container the
MariaDB container will be available with the hostname `mariadb`.  The MariaDB instance can be managed via the automatically installed SQLTools extension,
or from the container's command line with

```$ mariadb -h mariadb -u root -p```

the password is defined by default as `just-for-testing`, and if desired this may be changed in docker-compose.yml.

## Using this definition with an existing folder

Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the PHP 7 & MariaDB definition.

3. To use the latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of this folder in the cloned repository to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select this folder from the cloned repository.
5. Run the script `test-project/test.sh`


## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
