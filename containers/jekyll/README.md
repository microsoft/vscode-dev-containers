# Jekyll

## Summary

*Develop static sites with Jekyll, includes everything you need to get up and running.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Carlos Mendible](https://github.com/cmendible) |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | Ruby, Jekyll |

In addition to Ruby and Bundler, this development container installs Jekyll and the required tools at startup:

- If your Jekyll project contains a `Gemfile` in the root folder, the development container will install all gems at startup by running `bundle install`. This is the [recommended](https://jekyllrb.com/docs/step-by-step/10-deployment/#gemfile) approach as it allows you to specify the exact Jekyll version your project requires and list all additional Jekyll plugins.
- If there's no `Gemfile`, the development container will install Jekyll automatically, picking the latest version. You might need to manually install the other dependencies your project relies on, including all relevant Jekyll plugins.

## Using this definition with an existing folder

Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Jekyll definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/jekyll/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
