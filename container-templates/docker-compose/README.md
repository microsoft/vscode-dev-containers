# [Name of Definition Here] (Community)

## Summary

*[A short description of the the purpose of the definition goes here.]*

| Metadata                    | Value                                                                        |
|---------------------------- | -----------------------------------------------------------------------------|
| *Contributors*              | [Your name, GitHub profile]                                                  |
| *Categories*                | Community, [Languages, Frameworks, Services, Azure, GCP, AWS, GitHub, Other] |
| *Definition type*           | Docker Compose                                                               |
| *Works in Codespaces*       | Yes / No                                                                     |
| *Container host OS support* | Linux, macOS, Windows                                                        |
| *Container OS*              | [OS used by container - e.g. Debian]                                          |
| *Languages, platforms*      | [Languages and platforms the container supports]                             |

## [Optional] Description

**[Give a more detailed description of the container if the summary does not provide enough info.]**

## Using this definition

**[Optional] Include any special setup requirements here. For example:**

While the definition itself works unmodified, you can select the version of **YOUR RUNTIME HERE** the container uses by updating the `VARIANT` arg in the included `.devcontainer/docker-compose.yml` file.

```yaml
args:
  VARIANT: buster
```

### Adding another service

You can add other services to your `docker-compose.yml` file [as described in Docker's documentation](https://docs.docker.com/compose/compose-file/#service-configuration-reference). However, if you want anything running in this service to be available in the container on localhost, or want to forward the service locally, be sure to add this line to the service config:

```yaml
# Runs the service on the same network as the app container, allows "forwardPorts" in devcontainer.json function.
network_mode: service:app
```

### Adding the definition to a project or codespace

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers or [creating a codespace](https://aka.ms/ghcs-open-codespace) using GitHub Codespaces.

2. Start VS Code and open your project folder or connect to a codespace.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers** or **Codespaces**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** or **Codespaces: Rebuild Container** to start using the definition.

## [Optional] Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select this folder from the cloned repository.
5. **[Provide any information on steps required to test the definition.]**

## [Optional] How it works

**[If the definition provides a pattern you think will be useful for others, describe the it here.]**

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/main/LICENSE).
