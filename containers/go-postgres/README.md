# Go

- [Go](#go)
  - [Summary](#summary)
  - [Using this definition](#using-this-definition)
    - [Installing Node.js](#installing-nodejs)
    - [Adding the definition to a project or codespace](#adding-the-definition-to-a-project-or-codespace)
  - [Using the PostgreSQL Database](#using-the-postgresql-database)
    - [Adding another service](#adding-another-service)
    - [Installing GO Dependencies](#installing-go-dependencies)
  - [Testing the definition](#testing-the-definition)
    - [Debugging Security](#debugging-security)
  - [License](#license)

## Summary

*Use and develop Go + Postgres applications. Includes appropriate runtime args, Go, common tools, extensions, and dependencies.*

| Metadata | Value |
|----------|-------|
| *Contributors* | The VS Code Team |
| *Categories* | Core, Languages |
| *Definition type* | Dockerfile |
| *Available image variants* | 1 / 1-bullseye, 1.16 / 1.16-bullseye, 1.17 / 1.17-bullseye, 1-buster, 1.17-buster, 1.16-buster ([full list](https://mcr.microsoft.com/v2/vscode/devcontainers/go/tags/list)) |
| *Published image architecture(s)* | x86-64, arm64/aarch64 for `bullseye` variants |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Go |

See **[history](history)** for information on the contents of published images.

## Using this definition
This definition creates two containers, one for Go and one for PostgreSQL. VS Code will attach to the Go container, and from within that container the PostgreSQL container will be available on **`localhost`** port 5432. The default database is named `postgres` with a user of `postgres` whose password is `postgres`, and if desired this may be changed in `docker-compose.yml`. Data is stored in a volume named `postgres-data`.

While the definition itself works unmodified, you can select the version of Go the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
// Or you can use 1.17-bullseye or 1.17-buster if you want to pin to an OS version
"args": { "VARIANT": "1.17" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own  `Dockerfile` to one of the following. An example `Dockerfile` is included in this repository.

- `mcr.microsoft.com/vscode/devcontainers/go` (latest)
- `mcr.microsoft.com/vscode/devcontainers/go:1` (or `1-bullseye`, `1-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/go:1.16` (or `1.16-bullseye`, `1.16-buster` to pin to an OS version)
- `mcr.microsoft.com/vscode/devcontainers/go:1.17` (or `1.17-bullseye`, `1.17-buster` to pin to an OS version)

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `mcr.microsoft.com/vscode/devcontainers/go:0-1.16` (or `0-1.16-bullseye`, `0-1.16-buster`)
- `mcr.microsoft.com/vscode/devcontainers/go:0.205-1.16` (or `0.205-1.16-bullseye`, `0.205-1.16-buster`)
- `mcr.microsoft.com/vscode/devcontainers/go:0.205.0-1.16` (or `0.205.0-1.16-bullseye`, `0.205.0-1.16-buster`)

However, we only do security patching on the latest [non-breaking, in support](https://github.com/microsoft/vscode-dev-containers/issues/532) versions of images (e.g. `0-1.16`). You may want to run `apt-get update && apt-get upgrade` in your Dockerfile if you lock to a more specific version to at least pick up OS security updates.

See [history](history) for information on the contents of each version and [here for a complete list of available tags](https://mcr.microsoft.com/v2/vscode/devcontainers/go/tags/list).

Alternatively, you can use the contents of `base.Dockerfile` to fully customize your container's contents or to build it for a container host architecture not supported by the image.

### Installing Node.js

Given JavaScript front-end web client code written for use in conjunction with a Go back-end often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.

```jsonc
"args": {
    "VARIANT": "1",
    "NODE_VERSION": "14" // Set to "none" to skip Node.js installation
}
```

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. To use the pre-built image:
   1. Start VS Code and open your project folder or connect to a codespace.
   2. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.
   4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

3. To build a custom version of the image instead:
   1. Clone this repository locally.
   2. Start VS Code and open your project folder or connect to a codespace.
   3. Use your local operating system's file explorer to drag-and-drop the locally cloned copy of the `.devcontainer` folder for this definition into the VS Code file explorer for your opened project or codespace.
   4. Update `.devcontainer/devcontainer.json` to reference `"dockerfile": "base.Dockerfile"`.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## Using the PostgreSQL Database
You can connect to PostgreSQL from an external tool when using VS Code by updating `.devcontainer/devcontainer.json` as follows:

```json
"forwardPorts": [ "5432" ]
```

Once the PostgreSQL container has port forwarding enabled, it will be accessible from the Host machine at `localhost:5432`. The [PostgreSQL Documentation](https://www.postgresql.org/docs/14/index.html) has:

1. [An Installation Guide for PSQL], a CLI tool to work with a PostgreSQL database.
2. [Tips on populating data](https://www.postgresql.org/docs/14/populate.html) in the database. 

If needed, you can use `postCreateCommand` to run commands after the container is created, by updating `.devcontainer/devcontainer.json` similar to what follows:

```json
"postCreateCommand": "go version && git --version && node --version"
```

### Adding another service

You can add other services to your `docker-compose.yml` file [as described in Docker's documentation](https://docs.docker.com/compose/compose-file/#service-configuration-reference). However, if you want anything running in this service to be available in the container on localhost, or want to forward the service locally, be sure to add this line to the service config:

```yaml
# Runs the service on the same network as the database container, allows "forwardPorts" in devcontainer.json function.
network_mode: service:db
```

### Installing GO Dependencies

This definition includes the popular [PostGres Driver Library for Go](github.com/lib/pq). This is the recommended driver for use with Go, as per [GoLang Documentation](https://golangdocs.com/golang-postgresql-example).

If you wish to change this, you may add additional `RUN` commands in the [Go Dockerfile](.devcontainer/Dockerfile). For example:

```yaml
# This line can be modified to add any needed additional packages
RUN go get -x <github-link-for-package>
```

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/go` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. From here the following should print out in the Debug Console:
   ```
   Connected!
   Sending Query to Database
   One database in this cluster is: postgres
   ```
7. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.
8. The Application can also be tested by running `./test.sh` from the Terminal. This will test the `hello.go` application.


### Debugging Security
To allow C++ debuggers to run within the Docker Containers, the [docker-compose.yml](.devcontainer/docker-compose.yml) contains the following lines:

```yaml
    security_opt:
      - seccomp:unconfined
    cap_add:
      - SYS_PTRACE
```

As these can create security vulnerabilities, it is advisable to not use this unless needed. This should only be used in a Debug or Dev container, not in Production.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
