# Ruby on Rails (Community)

## Summary

_Develop Ruby on Rails applications, includes everything you need to get up and running._

| Metadata                    | Value                 |
| --------------------------- | --------------------- |
| _Contributors_              | [Amblizer][la]        |
| _Categories_                | Community, Frameworks |
| _Definition type_           | Dockerfile            |
| _Works in Codespaces_       | Yes                   |
| _Container host OS support_ | Linux, macOS, Windows |
| _Container OS_              | Debian                |
| _Languages, platforms_      | Ruby                  |

## Using this definition

While this definition should work unmodified, you can select the version of Ruby the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "2.7" }
```

This container also includes Node.js. You can change the version of Node.js by updating the `args` property in `.devcontainer/devcontainer.json`.

```jsonc
"args": {
    "VARIANT": "2",
    "NODE_VERSION": "14" // Set to "none" to skip Node.js installation
}
```

In the [Dockerfile](./.devcontainer/Dockerfile), this container also supports serving a development server over a GitHub Codespace port-forwarded domain. This is necessary due to [Rails 6 adding guards against DNS rebinding attacks](https://blog.saeloun.com/2019/10/31/rails-6-adds-guard-against-dns-rebinding-attacks.html)/

The environment variable's value is a comma-separated list of allowed domains, and is only honored in Rails version **7.0.0+**.

```dockerfile
# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev <, YOUR_OTHER_ALLOWED_DOMAIN(S), ...>"
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
4. Select the `containers/ruby-rails` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "\* Listening on tcp://0.0.0.0:3000" in the Debug Console.
7. Press <kbd>F1</kbd>. Select **Forward a Port** then choose **Forward 3000**.
8. By browsing http://localhost:3000/ you should see "Yay! You’re on Rails!".
9. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).

<!-- links -->

[la]: https://code.mzhao.page/
