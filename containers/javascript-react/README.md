# React and Javascript

## Summary

*Create react web applications on Linux*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Mehant](mailto:kmehant@gmail.com) |
| *Definition type* | Dockerfile |
| *Languages, platforms* | React, JavaScript |

## Using this definition with an existing folder

This definition does not require any special steps to use. Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Create Container Configuration File...** from the command palette.
   3. Select the Javascript React definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/javascript-react/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes a sample react app project that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/javascript-react` folder.
5. After the folder has opened in the container, run the command `cd sample-project && npm start` this starts the development server.
6. Once the react app is running, press <kbd>F1</kbd> and select **Remote-Containers: Forward Port from Container...**
7. Select port 3000 and click the "Open Browser" button in the notification that appears.
8. You should see spinning react symbol after the page loads.
9. For debugging, ensure that your development server is running and then press <kbd>F5</kbd> or the green arrow to launch the debugger and open a new browser instance.
10. From here, you can add breakpoints or edit the contents of the `sample-project` folder to do further testing. You can use this as reference [Debugging React App](https://code.visualstudio.com/docs/nodejs/reactjs-tutorial#_debugging-react)


## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).