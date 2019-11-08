# Node.js 12 & Mongo DB

## Summary

*Develop applications in Node.js and Mongo DB. Includes Node.js, eslint, and yarn in a container linked to a Mongo DB.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Definition type* | Docker Compose |
| *Languages, platforms* | Node.js, JavaScript, Mongo DB |

This definition does not require any special steps to use. Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Node.js (latest LTS) & Mongo DB definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/javascript-node-lts-mongo/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/javascript-node-lts-mongo` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project. This will automatically run `npm install` before starting it.
6. Once the project is running, press <kbd>F1</kbd> and select **Remote-Containers: Forward Port from Container...**
7. Select port 3000 and click the "Open Browser" button in the notification that appears.
8. You should see "Hello remote world! 1 test record(s) found." after the page loads.
9. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).