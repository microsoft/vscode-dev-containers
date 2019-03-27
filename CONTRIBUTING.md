# Contributing

Have a container set up you're proud of and would like to share? Want to see some changes made to an existing definition? We love contributions and suggestions!  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Contributing a definition

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
       📁 .devcontainer
          📄 Dockerfile (optional)
          📄 docker-compose.yml (optional)
          📄 ignore
       📁 test-project (optional)
       📄 README.md
    ```

    See [VS Code Remote's documentation](https://aka.ms/vscode-remote/docker) for information on the expected contents of `devContainer.json` and how it relates to other files listed above.
    
    Note that any additional assets can be included as needed, but keep in mind that these will overlay on top of an existing project. Anything you don't want added to a project should be referenced in [glob](https://facelessuser.github.io/wcmatch/glob/) form in `.devcontainer/ignore` with paths relative to the location of the `ignore` file. Create a `README.md` in the folder with a brief description of the purpose of the container definition and any manual steps required to use it.

4. Commit your changes and submit a PR - we'll take a look at it, provide any needed feedback, and then merge it in! We appreciate any and all feedback!!

## Developing and testing a definition

VS Code Remote provides a straight forward development loop for creating and editing container definitions. Just follow these steps to get started:

1. Create a definition folder and open it in VS Code
2. Edit the contents of the definition
3. Run the **Remote: Reopen Folder in Container** command
4. If this fails, click "Open folder locally" in the dialog that appears and go to step 2
6. If it opens successfully but you don't like the contents, edit the contents from within the container and run the **Remote: Rebuild Container** command to make changes.

Note that if you make major changes, Docker may occasionally not pick up your edits. If this happens, you can delete the existing container and image, open the folder locally, and go to step 2 above. Install the [Docker extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) locally (when not in a container) to make this easy. While you can use Docker from inside a container by forwarding the Docker unix socket and installing the CLI in the container (see [Docker-in-Docker](containers/docker-in-docker)), you'll likely be removing the container you are actually using so this approach will not work well in this case.

Finally, after you get your container up and running, you can test it by adding test assets into the definition folder as long as they are referenced in the `.devcontainer/ignore` file in [glob](https://facelessuser.github.io/wcmatch/glob/) form ith paths relative to the location of the `ignore` file. By convention, most definitions place test assets in a `test-project` folder and this path is referenced in the template `ignore` files. 

## Speeding up container provisioning

While using a `Dockerfile` is a convienent way to get going with a new container definition, this method can slow down the process of creating the dev container since it requires the image be built by anyone using it.  If your definition is stable, we strongly reccomend building and publishing your image to [DockerHub](https://hub.docker.com) or [Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry/) instead. 

Once you've published your container image, just update `devContainer.json` to reference the image instead of the `Dockerfile`. See `container-templates/image` for an example.

## License

Copyright (c) Microsoft Corporation. All rights reserved.<br />
Licensed under the MIT License. See [LICENSE](../LICENSE). 
