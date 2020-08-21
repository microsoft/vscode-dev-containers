# Node.js & PostgreSQL

## Summary

*Develop applications in Node.js and PostgreSQL. Includes Node.js, eslint, and yarn in a container linked to a Postgres DB container*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Mehant](mailto:kmehant@gmail.com) |
| *Definition type* | Docker Compose |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Node.js, JavaScript, PostgreSQL DB |

## Description

> **Note:** Inside the container, you will find PostgreSQL running at `db:5432` rather than localhost.

This definition creates two containers, one for Node.js and one for PostgreSQL. VS Code will attach to the Node.js container, and from within that container the PostgreSQL container will be available with the hostname `db`. The default database is named `postgres` with a user of `postgres` whose password is `LocalPassword`, and if desired this may be changed in `docker-compose.yml`.

While the definition itself works unmodified, it uses the `mcr.microsoft.com/vscode/devcontainers/javascript-node` image which includes `git`, `eslint`, `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development. You can pick a different version of this image by updating the `VARIANT` arg in `.devcontainer/docker-compose.yml` to pick either Node.js version 10, 12, or 14.

```yaml
build:
  context: .
  dockerfile: Dockerfile
  args:
    VARIANT: 12
```

The PostgreSQL instance can be managed via the automatically installed SQLTools extension, or you can expose the database to your local machine by uncommenting the following line in `.devcontainer/docker-compose.yaml`:

```yaml
ports:
  - 5432:5432
```

### Adding the definition to your project

Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Node.js & Postgres DB definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/javascript-node-postgres/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/javascript-node-postgres` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project. This will automatically run `npm install` before starting it.
6. Once the project is running, press <kbd>F1</kbd> and select **Remote-Containers: Forward Port from Container...**
7. Select port 3000 and click the "Open Browser" button in the notification that appears.
8. You should see "Hello remote world! Successfully connected to database." after the page loads.
9. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).