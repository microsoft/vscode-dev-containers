# Elixir, Phoenix, Node.js & PostgresSQL (Community)

## Summary

_Develop Elixir/Phoenix based applications. Includes everything you need to get up and running._

| Metadata                    | Value                 |
| --------------------------- | --------------------- |
| _Contributors_              | [idyll](https://github.com/idyll), [Talk2MeGooseman](https://github.com/talk2MeGooseman)|
| _Category_                  | Community, Languages, Frameworks  |
| _Definition type_           | Dockerfile            |
| _Works in Codespaces_       | Yes                   |
| _Container host OS support_ | Linux, macOS, Windows |
| _Languages, platforms_      | Elixir, Postgres DB   |

## Using this definition

While this definition should work unmodified, you can select the version of Elixir the container uses by updating the `VARIANT` arg in the included `docker-compose.yml`. In the same way you can specify a Phoenix Version by modifying the `PHOENIX_VERSION`.

```yml
services:
  elixir:
    build: .
    args:
      # Elixir Version: 1.9, 1.10, 1.10.4, ...
      VARIANT: 1.10
      # Phoenix Version: 1.4.17, 1.5.4, ...
      PHOENIX_VERSION: 1.5.4
      # ...
```

### Installing Node.js

Given that Phoenix/Elixir web applications use Node.js for compiling assets, this container also includes Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/docker-compose.yml`.

```yml
services:
  elixir:
    build: .
    args:
      # ...
      # Node Version: 10, 11, ...
      NODE_VERSION: 14
      # ...
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
4. Select the `containers/elixir-phoenix-postgres` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "Hello, Remote Extension Host!" followed by "Hello, Local Extension Host!" in the Debug Console after the program executes.
7. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
