# Ruby on Rails & Postgres

## Summary

*Develop Ruby on Rails applications with Postgres. Includes a Rails application container and PostgreSQL server.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Jarrod Davis][jld], the VS Code Team |
| *Categories* | Core, Frameworks |
| *Definition type* | Docker Compose |
| *Works in Codespaces* | Yes |
| *Available image variants* | [See Ruby definition](../ruby). |
| *Supported architecture(s)* | x86-64, arm64/aarch64 for `bullseye` based images |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Ruby |

## Using this definition with an existing folder

This definition creates two containers, one for Ruby and one for PostgreSQL. VS Code will attach to the Ruby container, and from within that container the PostgreSQL container will be available on **`localhost`** port 5432. The default database is named `postgres` with a user of `postgres` whose password is `postgres`, and an additional user (`vscode`) is added to support common Rails development database configurations. You can use `rake db:setup` (or `rake db:create`) to setup the databases your Rails application needs for development and testing. Data is stored in a volume named `postgres-data`.

While the definition itself works (mostly) unmodified, it uses the `mcr.microsoft.com/vscode/devcontainers/ruby` image which includes `git`, `zsh`, [Oh My Zsh!](https://ohmyz.sh/), and a non-root `vscode` user with `sudo` access. You can pick a different version of this image by updating the `VARIANT` arg in `.devcontainer/docker-compose.yml` to pick a Ruby version.

```yaml
build:
  context: ..
  dockerfile: .devcontainer/Dockerfile
  args:
    # Update 'VARIANT' to pick a version of Ruby: 3, 3.0, 2, 2.7, 2.6
    # Append -bullseye or -buster to pin to an OS version.
    # Use -bullseye variants on local arm64/Apple Silicon.
    VARIANT: "2-bullseye"
```

You can connect to PostgreSQL from an external tool when using VS Code by updating `.devcontainer/devcontainer.json` as follows:

```json
"forwardPorts": [ "5432" ]
```

### Adding another service

You can add other services to your `docker-compose.yml` file [as described in Docker's documentation](https://docs.docker.com/compose/compose-file/#service-configuration-reference). However, if you want anything running in this service to be available in the container on localhost, or want to forward the service locally, be sure to add this line to the service config:

```yaml
# Runs the service on the same network as the database container, allows "forwardPorts" in devcontainer.json function.
network_mode: service:db
```

### Installing Node.js

This container also includes Node.js. You can change the version of Node.js by updating the `args` property in `.devcontainer/docker-compose.yml`.

```yaml
args:
  VARIANT: "2-bullseye"
  NODE_VERSION: "14" # Set to "none" to skip Node.js installation
```

### Adding the definition to your folder

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To start then:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Ruby on Rails definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of the `.devcontainer` folder under `containers/ruby-rails-postgres/` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/ruby-rails-postgres` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "* Listening on tcp://0.0.0.0:3000" in the Debug Console. 
7. Press <kbd>F1</kbd>. Select **Forward a Port** then choose **Forward 3000**.
8. By browsing http://localhost:3000/ you should see "Yay! You’re on Rails!".
9. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).

<!-- links -->
[jld]: https://github.com/jarrodldavis
