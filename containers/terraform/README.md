# Terraform (Community)

## Summary

_Develop and test terraform script within container_

| Metadata                    | Value                                                                         |
| --------------------------- | ----------------------------------------------------------------------------- |
| _Contributors_              | [Shashindran Vijayan](https://github.com/Shashindran)                         |
| _Categories_                | Community, Languages                                                          |
| _Definition type_           | Dockerfile                                                                    |
| _Published images_          | hub.docker.com/r/hashicorp/terraform                                          |
| _Available image variants_  | 1.1.2, 1.1.1 ([full list](https://hub.docker.com/r/hashicorp/terraform/tags)) |
| _Container host OS support_ | Linux, macOS, Windows                                                         |
| _Container OS_              | Alpine Linux                                                                  |
| _Languages, platforms_      | Terraform                                                                     |

## Using this definition

This development container installs terraform and enables terraform command executions within VS Code terminal.

While this definition should work unmodified, you can select the version of Terraform the container uses by updating the `TF_VERSION` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": {
  "TF_VERSION": "1.1.2"
}
```

### Adding the definition to a project

1. If this is your first time using a development container, please see getting started information on [setting up](https://aka.ms/vscode-remote/containers/getting-started) Remote-Containers

2. Start VS Code and open your project folder.

3. Press <kbd>F1</kbd> select and **Add Development Container Configuration Files...** command for **Remote-Containers**.

   > **Note:** If needed, you can drag-and-drop the `.devcontainer` folder from this sub-folder in a locally cloned copy of this repository into the VS Code file explorer instead of using the command.

4. Select this definition. You may also need to select **Show All Definitions...** for it to appear.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).
