# Visual Studio Code Remote Development Container Definitions

A **development container** is a running Docker container that comes with a basic tool stack (Python, node, Go, etc.) and its prerequisites (e.g. `pylint` for Python). This container may be used to actually run an application or be focused exclusively on sandboxing tools, libraries, runtimes, or other utilities that need to be run against a codebase.

Visual Studio Code Remote allows you to open any folder inside (or mounted into) a dev container and take advantage of VS Code's full feature set. When using the capability, VS Code selectively runs certain extensions in the container to optimize your experience. The result is that VS Code can provide a local-quality development experience including full IntelliSense, debugging, and more regardless of where your code is located. 

**[See here to learn more about VS Code Remote](https://aka.ms/vscode-remote/docker)**.

This repository contains a set of **dev container definitions** made up of files like `devContainer.json` that can be added to existing projects to get you up and running in a containerized environment. These files describe the container image, any runtime arguments for when the container is started, and any VS Code extensions that should be installed into it.

## Trying a definition

1. Click on one of the `containers` sub-folders to open it in your browser
2. Check out the README to see if there are any manual steps
3. Clone this repository or copy the contents of the folder to your machine
4. Run the **Remote: Open Folder in Container...** command in VS Code
5. Select the definition folder in the "open" dialog

Many definitions include a `test-project` that you can use to see the dev container in action. Note that if you open this folder locally instead, you'll be prompted to reopen it in a container as well. You can also use the **Remote: Reopen Folder in Container** command at any time.

## Using a definition

You can either:

- Run **Remote: Create Container Configuration File...** command in VS Code and pick a definition. The appropriate files will then be added to your project.

- Manually copy the contents of one of the `containers` sub-folders into your project. When manually copying, note that some definitions contain a `test-project` folder and/or `.vscode/launch.json`, `.vscode/settings.json`, or `.vscode/tasks.json` files. These and `README.md` and `.vscodeignore` can typically be omitted.

## Adding a definition to an existing public or private repo

Files like `.vscode/devContainer.json` that make up each dev container definition in the `containers` folder can to be modified as needed and then committed into your own project's source control repo for reuse by others. 

By committing these files to source control, anyone with the [Remote Development](https://aka.ms/vscode-remote/download/extension) extension installed in VS Code that opens a cloned copy of your repo will be asked if they want reopen the folder in a container instead. You can also suggest that they install the Remote Development extension if they do not have it by adding it to the `recommendations` list in `.vscode/extensions.json` (as described [here](https://code.visualstudio.com/docs/editor/extension-gallery#_workspace-recommended-extensions)).

Beyond the advantages of having your team use a consistent environment and tool-chain, doing this can make it easier for new contributors or team members to get productive quickly. First-time contributors will require less guidance and are less likely to either submit issues or contribute code with issues that are related to environment setup.

## Contents

- `containers` - Dev container definition folders. 
- `container-templates` - Templates for creating your own container definitions in your project or for contributing back to this repository.

## Contributing

Have a container set up you're proud of and would like to share? Want to see some changes made to an existing definition? Great! we love contributions! Read on to get a sense of what you'll need to do.

### Contributing a definition

If you want to create a new definition:

1. Fork and clone this repository

2. Create a new folder in the `containers` directory. The name of the folder is effectively the **definition ID** and should follow the following format:

    ````
    <language>-<optional: version>-<descriptor>
    ````

    You'll find many examples in the current `containers` folder.

3. You can grab one of the templates from the `container-templates` folder to help you get an idea of what to contribute for different scenarios, but here's a quick summary of what you should include:

    ```
    📁 <language>-<optional: version>-<descriptor>
       📁 .vscode
          📄 devContainer.json
       📁 test-project (optional)
       📄 dev-container.dockerfile (optional)
       📄 docker-compose.dev-container.yml (optional)
       📄 .vscodeignore
       📄 README.md
    ```

    See [VS Code Remote's documentation](https://aka.ms/vscode-remote/docker) for information on the expected contents of `devContainer.json` and how it relates to other files listed above.
    
    Note that any additional assets can be included as needed, but keep in mind that these will overlay on top of an existing project. Anything you don't want added to a project should be referenced in [glob](https://facelessuser.github.io/wcmatch/glob/) form in `.vscodeignore`. Create a `README.md` in the folder with a brief description of the purpose of the container definition and any manual steps required to use it.

4. Commit your changes and submit a PR - we'll take a look at it, provide any needed feedback, and then merge it in! We appreciate any and all feedback!!

### Developing and testing a definition

VS Code Remote provides a straight forward development loop for creating and editing container definitions. Just follow these steps to get started:

1. Create a definition folder and open it in VS Code
2. Edit the contents of the definition
3. Run the **Remote: Reopen Folder in Container** command
4. If this fails, click "Open folder locally" in the dialog that appears and go to step 2
6. If it opens successfully but you don't like the contents, edit the contents from within the container and run the **Remote: Rebuild Container** command to make changes.

Note that if you make major changes, Docker may occasionally not pick up your edits. If this happens, you can delete the existing container and image, open the folder locally, and go to step 2 above. Install the [Docker extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) locally (when not in a container) to make this easy. While you can use Docker from inside a container by forwarding the Docker unix socket and installing the CLI in the container (see [Docker-in-Docker](containers/docker-in-docker)), you'll likely be removing the container you are actually using so this approach will not work well in this case.

Finally, after you get your container up and running, you can test it by adding test assets into the definition folder as long as they are referenced in the `.vscodeignore` file in [glob](https://facelessuser.github.io/wcmatch/glob/) form. By convention, most definitions place test assets in a `test-project` folder. 

### Speeding up container provisioning

While using a `Dockerfile` is a convienent way to get going with a new container definition, this method can slow down the process of creating the dev container since it requires the image be built by anyone using it.  If your definition is stable, we strongly reccomend building and publishing your image to [DockerHub](https://hub.docker.com) or [Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry/) instead. 

Once you've published your container image, just update `devContainer.json` to reference the image instead of the `Dockerfile`. See `container-templates/image` for an example.

### Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](LICENSE). 
