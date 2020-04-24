# Java 8 & Tomcat 8.5

## Summary

*Develop and run Java applications in Tomcat Server. Includes Tomcat 8.5, JDK 8, Maven build tools.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Java Team |
| *Definition type* | Dockerfile |
| *Container host OS support* | Linux, macOS, Windows |
| *Languages, platforms* | Tomcat, Java, Maven |

## Using this definition with an existing folder

Follow these steps to use the definition:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Java 8 & Tomcat 8.5 definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of `containers/java-8-tomcat-8.5/.devcontainer` to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/java-8-tomcat-8.5` folder.
5. After the folder has opened in the container, press <kbd>F1</kbd>, and select **Tomcat: Add Tomcat Server**.
6. Select `/usr/local/tomcat` as the path and click **OK** to add a new Tomcat Server.
7. Press <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>`</kbd> to open a new terminal, then run the commands below to generate a war file.
    ```
    cd test-project
    mvn clean package
    ```
8. Navigate to `test-project/target/mywebapp-0.0.1-SNAPSHOT.war` in the explorer, right-click on the file, and select **Debug on Tomcat Server**
9. The application will then start in the Tomcat Server!

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
