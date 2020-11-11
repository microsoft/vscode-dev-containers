# PHP & MariaDB

## Summary

Develop PHP based applications with MariaDB (MySQL Compatible).  Includes necessary extensions and tools for both PHP and MariaDB.

| Metadata | Value |  
|----------|-------|
| *Contributors* | Richard Morrill [github.com/ThoolooExpress](https://github.com/ThoolooExpress) |
| *Definition type* | Docker Compose |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | PHP, MariaDB (MySQL Compatible) |

## Description

This definition creates two containers, one for PHP and one for MariaDB.  Code will attach to the PHP container, and from within that container the MariaDB container will be available on **`localhost`** port 3306. The MariaDB instance can be managed via the automatically installed SQLTools extension, or from the container's command line with:

```bash
mariadb -h localhost -P 3306  --protocol=tcp -u root --password=mariadb -D mariadb
```

The default database is called `mariadb` with a `mariadb` user whose password is `mariadb`, and if desired this may be changed in `docker-compose.yml`. Data is stored in a volume named `mariadb-data`. Note that you will **not** be able to access the MariaDB socket, so be sure to specify `--protocol=tcp` when using the command line.

## Using this definition with an existing folder

While the definition itself works unmodified, you can select the version of PHP the container uses by updating the `VARIANT` arg in the included `.devcontainer/docker-compose.yml` (and rebuilding if you've already created the container).

```yaml
build:
  context: .
  dockerfile: Dockerfile
  args:
    VARIANT: "7"
```

Given how frequently web applications use Node.js for front end code, this container also includes an optional install of Node.js. You can enable installation and change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/docker-compose.yml`.

```yaml
args:
  VARIANT: "7"
  INSTALL_NODE: "true"
  NODE_VERSION: "10"
```

You also can connect to MariaDB from an external tool when using VS Code by updating `.devcontainer/devcontainer.json` as follows:

```json
"forwardPorts": [ "3306" ]
```

### Adding another service

You can add other services to your `docker-compose.yml` file [as described in Docker's documentation](https://docs.docker.com/compose/compose-file/#service-configuration-reference). However, if you want anything running in this service to be available in the container on localhost, or want to forward the service locally, be sure to add this line to the service config:

```yaml
# Runs the service on the same network as the database container, allows "forwardPorts" in devcontainer.json function.
network_mode: service:db
```

### Starting / stopping Apache

This dev container includes Apache in addition to the PHP CLI. While you can use PHP's built in CLI (e.g. `php -S 0.0.0.0:8080`), you can start Apache by running:

```bash
apache2ctl start
```

Apache will be available on port `8080`.

If you want to wire in something directly from your source code into the `www` folder, you can add a symlink as follows to `postCreateCommand`:

```json
"postCreateCommand": "sudo chmod a+x \"$(pwd)\" && sudo rm -rf /var/www/html && sudo ln -s \"$(pwd)\" /var/www/html"
```

...or execute this from a terminal window once the container is up:

```bash
sudo chmod a+x "$(pwd)" && sudo rm -rf /var/www/html && sudo ln -s "$(pwd)" /var/www/html
```

### Adding the definition to your project

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the PHP & MariaDB definition.

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
