# Java & PostgreSQL

## Summary

*Develop applications with Java and PostgreSQL. Includes a Java application container and PostgreSQL server.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Java Team |
| *Categories* | Core, Languages |
| *Definition type* | Docker Compose |
| *Available image variants* | [See Java definition](../java). |
| *Supported architecture(s)* | x86-64, arm64/aarch64 for `bullseye` variants |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Java |

## Table of Contents

- [Java & PostgreSQL](#java--postgresql)
  - [Summary](#summary)
  - [Using this definition](#using-this-definition)
    - [Adding another service](#adding-another-service)
    - [Debug Configuration](#debug-configuration)
    - [Installing Maven or Gradle](#installing-maven-or-gradle)
    - [Installing Node.js](#installing-nodejs)
    - [Adding the definition to your folder](#adding-the-definition-to-your-folder)
  - [Testing the definition](#testing-the-definition)
  - [Testing the PostgreSQL container](#testing-the-postgresql-container)
  - [License](#license)


## Using this definition

This definition creates two containers, one for Java and one for PostgreSQL. VS Code will attach to the Java container, and from within that container the PostgreSQL container will be available on **`localhost`** port 5432. The default database is named `postgres` with a user of `postgres` whose password is `postgres`, and if desired this may be changed in `docker-compose.yml`. Data is stored in a volume named `postgres-data`.

While the definition itself works unmodified, it uses the `mcr.microsoft.com/vscode/devcontainers/java` image which includes `git`, a non-root `vscode` user with `sudo` access, and a set of common dependencies and Java tools for development. You can pick a different version of this image by updating the `VARIANT` arg in `.devcontainer/docker-compose.yml` to pick a Java version.

```yaml
build:
  context: ..
  dockerfile: .devcontainer/Dockerfile
    args:
      # Update 'VARIANT' to pick an version of Java: 11, 17.
      # Append -bullseye or -buster to pin to an OS version.
      # Use -bullseye variants on local arm64/Apple Silicon.
      VARIANT: 11-bullseye
```

You also can connect to PostgreSQL from an external tool when using VS Code by updating `.devcontainer/devcontainer.json` as follows:

```json
"forwardPorts": [ "5432" ]
```

Once the PostgreSQL container has port forwarding enabled, it will be accessible from the Host machine at `localhost:5432`. The [PostgreSQL Documentation](https://www.postgresql.org/docs/14/index.html) has:

1. [An Installation Guide for PSQL](https://www.postgresql.org/docs/14/installation.html) a CLI tool to work with a PostgreSQL database.
2. [Tips on populating data](https://www.postgresql.org/docs/14/populate.html) in the database. 

If needed, you can use `postCreateCommand` to run commands after the container is created, by updating `.devcontainer/devcontainer.json` similar to what follows:

```json
"postCreateCommand": "java -version && git --version && node --version"
```

### Adding another service

You can add other services to your `docker-compose.yml` file [as described in Docker's documentation](https://docs.docker.com/compose/compose-file/#service-configuration-reference). However, if you want anything running in this service to be available in the container on localhost, or want to forward the service locally, be sure to add this line to the service config:

```yaml
# Runs the service on the same network as the database container, allows "forwardPorts" in devcontainer.json function.
network_mode: service:db
```

### Debug Configuration

Note that only the integrated terminal is supported by the Remote - Containers extension. You may need to modify `launch.json` configurations to include the following value if an external console is used.

```json
"console": "integratedTerminal"
```

### Installing Maven or Gradle

You can opt to install a version of Maven or Gradle by adding `INSTALL_MAVEN: "true"` or `INSTALL_GRADLE: "true"` to build args in `.devcontainer/docker-compose.yml`. Both of these are set by default. For example:

```yaml
args:
  VARIANT: 11
  INSTALL_GRADLE: "true"
  INSTALL_MAVEN: "true"
```

Remove the appropriate arg or set its value to `"false"` to skip installing the specified tool.

You can also specify the version of Gradle or Maven if needed.

```yaml
args:
  VARIANT: 11
  INSTALL_GRADLE: "true"
  MAVEN_VERSION: "3.8.3"
  INSTALL_MAVEN: "true"
  GRADLE_VERSION: "7.2"
```

### Installing Node.js

Given JavaScript front-end web client code written for use in conjunction with a Java back-end often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can enable installation and change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/docker-compose.yml`.

```yaml
args:
  VARIANT: 11
  NODE_VERSION: "10" # Set to "none" to skip Node.js installation, or "lts/*" for latest
```

### Adding the definition to your folder

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/java-postgres` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "Hello Remote World!" in the a Debug Console after the program executes.
7. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## Testing the PostgreSQL container

The `docker-compose` file sets up a networked PostgreSQL database that is accessible from the Java Dev Container. The port is forwarded to `localhost:5432` by default, but can be changed in the [devcontainer.json](.devcontainer\devcontainer.json).

1. After starting the Dev Container as above, you can run the individual tests, which will output in the debug console.
2. The [AppTest.java](test-project\src\test\java\com\mycompany\app\AppTest.java) contains a Test Method, `testIP` which will ping the Postgres Database using it's default container name, `postgresdb`.
3. Running this test will let you know that the PostgreSQL DB is accessible. **This does not make or authorize a connection to the database, only checks for connectivity between containers.** You can run the tests either by:
   a. Hovering over individual tests and pressing the Green Play Button. This will compile the class and run a single test.
   b. Finding `AppTest.java`, right-clicking and hitting "Run Java". This will compile the class and run all tests.
5. Alternatively, running [./test.sh](test-project/test-utils.sh) will also run all the connectivity tests and verify that the PostgresDB is actually accessible. 

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
