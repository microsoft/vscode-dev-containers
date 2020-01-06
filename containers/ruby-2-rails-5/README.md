# Ruby 2 Rails 5

## Summary

*Develop Ruby on Rails 5 applications, includes everything you need to get up and running.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Amblizer][la] |
| *Definition type* | Dockerfile |
| *Languages, platforms* | Ruby |

## Using this definition with an existing folder

This definition does not require any special steps to use. Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To start then:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Ruby 2 rails 5 definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `.devcontainer` and `.vscode` folders under `containers/ruby-2-rails-5/` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/ruby-2-rails-5` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "* Listening on tcp://0.0.0.0:3000" in the Debug Console. 
7. Press <kbd>F1</kbd>. Select **Remote-Containers: Forward Port from Container...** then choose **Forward 3000**.
8. By browsing http://localhost:3000/ you should see "Yay! You’re on Rails!".
9. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).

<!-- links -->
[la]: https://code.mzhao.page/
