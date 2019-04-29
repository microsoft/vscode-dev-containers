# Contributing

This document outlines a number of ways you can get involved.

## Contributing Dev Container Definitions

Have a container set up you're proud of and would like to share? Want to see some changes made to an existing definition? We love contributions!  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

If you want to create a new definition:

1. Fork and clone this repository

2. Create a new folder in the `containers` directory. The name of the folder is effectively the **definition ID** and should follow the following format:

    ````text
    <language>-<optional: version>-<descriptor>
    ````

    You'll find many examples in the current `containers` folder.

3. You can grab one of the templates from the `container-templates` folder to help you get an idea of what to contribute for different scenarios, but here's a quick summary of what you should include:

    ```text
    📁 <language>-<optional: version>-<descriptor>
       📁 .devcontainer
          📄 devcontainer.json
          📄 Dockerfile (optional)
          📄 docker-compose.yml (optional)
       📁 test-project (optional)
       📄 .npmignore
       📄 README.md
    ```

    See the [VS Code Remote Development documentation](https://aka.ms/vscode-remote/docker) for information on the expected contents of `devcontainer.json` and how it relates to other files listed above.

    Note that any additional assets can be included as needed, but keep in mind that these will overlay on top of an existing project. Keeping these files in the `.devcontainer` folder should reduce the chances of something conflicting but note that any command that are run are relative to the root of the project, so you'll need to include `.devcontainer` in any path references.

    VS Code respects [`.npmignore`](https://docs.npmjs.com/misc/developers#keeping-files-out-of-your-package) as a way to keep certain content out of projects when your definition is used. Add anything you don't want copied across into this file in [glob](https://facelessuser.github.io/wcmatch/glob/) form.

    Finally, create a `README.md` in the folder with a brief description of the purpose of the container definition and any manual steps required to use it.

4. Commit your changes and submit a PR - we'll take a look at it, provide any needed feedback, and then merge it in. We appreciate any and all feedback!

### Developing and testing a definition

VS Code Remote provides a straight forward development loop for creating and editing container definitions. Just follow these steps to get started:

1. Create a definition folder and open it in VS Code
2. Edit the contents of the definition
3. Run the **Remote: Reopen Folder in Container** command
4. If this fails, click "Open folder locally" in the dialog that appears and go to step 2
6. If it opens successfully but you don't like the contents, edit the contents from within the container and run the **Remote: Rebuild Container** command to make changes.

Note that if you make major changes, Docker may occasionally not pick up your edits. If this happens, you can delete the existing container and image, open the folder locally, and go to step 2 above. Install the [Docker extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) locally (when not in a container) to make this easy. While you can use Docker from inside a container by forwarding the Docker unix socket and installing the CLI in the container (see [Docker-in-Docker](containers/docker-in-docker)), you'll likely be removing the container you are actually using so this approach will not work well in this case.

Finally, after you get your container up and running, you can test it by adding test assets into the definition folder and add them to the `.devcontainer/ignore` file in [glob](https://facelessuser.github.io/wcmatch/glob/) form relative to the root of the folder. By convention, most definitions place test assets in a `test-project` folder and this path is referenced in the template `ignore` files. 

### Speeding up container provisioning

While using a `Dockerfile` is a convienent way to get going with a new container definition, this method can slow down the process of creating the dev container since it requires the image be built by anyone using it.  If your definition is stable, we strongly reccomend building and publishing your image to [DockerHub](https://hub.docker.com) or [Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry/) instead. 

Once you've published your container image, just update `devcontainer.json` to reference the image instead of the `Dockerfile`. See `container-templates/image` for an example.

## Contributing to Documentation

The majority of VS Code Remote's documentation can be found in the [VS Code docs repository](https://github.com/Microsoft/vscode-docs). This is usually the best place to contribute, but if you have a correction or suggestion for the content found here, we welcome your contributions.

## Reporting Issues

Have you identified a reproducible problem in a dev container definition? We want to hear about it! Here's how you can make reporting your issue as effective as possible.

### Identify Where to Report

This repository is specifically for dev container definitions. If you are not looking to report an issue related to a container definition, you may want to report the issue in the feedback repository for [VS Code Remote Development extensions](https://github.com/Microsoft/vscode-remote-release). Or you may be looking for the [VS Code OSS](https://github.com/Microsoft/vscode) repository. However, note that, the VS Code project is distributed across multiple repositories. See the list of [Related Projects](https://github.com/Microsoft/vscode/wiki/Related-Projects) if you aren't sure which repo is correct.

### Look For an Existing Issue

Before you create a new issue, please do a search in [open issues](https://github.com/Microsoft/vscode-dev-containers/issues) to see if the issue or feature request has already been filed.

Be sure to scan through the [most popular](https://github.com/Microsoft/vscode-dev-containers/issues?q=is%3Aopen+is%3Aissue+label%3Afeature-request+sort%3Areactions-%2B1-desc) feature requests.

If you find your issue already exists, make relevant comments and add your [reaction](https://github.com/blog/2119-add-reactions-to-pull-requests-issues-and-comments). Use a reaction in place of a "+1" comment:

* 👍 - upvote
* 👎 - downvote

If you cannot find an existing issue that describes your bug or feature, create a new issue using the guidelines below.

### Writing Good Bug Reports and Feature Requests

File a single issue per problem and feature request. Do not enumerate multiple bugs or feature requests in the same issue.

Do not add your issue as a comment to an existing issue unless it's for the identical input. Many issues look similar, but have different causes.

The more information you can provide, the more likely someone will be successful at reproducing the issue and finding a fix.

Please include the following with each issue:

* Version of VS Code
  
* Your operating system

* Include any modifications to container configuration files you've made if possible.

* List of extensions that you have installed

* Reproducible steps (1... 2... 3...) that cause the issue

* What you expected to see, versus what you actually saw

* Images, animations, or a link to a video showing the issue occurring

* A code snippet that demonstrates the issue or a link to a code repository the developers can easily pull down to recreate the issue locally

  * **Note:** Because the developers need to copy and paste the code snippet, including a code snippet as a media file (i.e. `.gif`) is not sufficient.

* Errors from the Dev Tools Console (open from the menu: **Help > Toggle Developer Tools**)
  
### Final Checklist

Please remember to do the following:

* [ ] Search the issue repository to ensure your report is a new issue

* [ ] Recreate the issue after disabling all extensions

* [ ] Simplify your code around the issue to better isolate the problem

Don't feel bad if the developers can't reproduce the issue right away. They will simply ask for more information!

### Follow Your Issue

Once submitted, your report will go into a similar [issue tracking](https://github.com/Microsoft/vscode/wiki/Issue-Tracking) workflow that is used for the VS Code project. Be sure to understand what will happen next, so you know what to expect, and how to continue to assist throughout the process.

### Automated Issue Management

We use a bot to help us manage issues. This bot currently:

* Automatically closes any issue marked `needs-more-info` if there has been no response in the past 7 days.
* Automatically locks issues 45 days after they are closed.

If you believe the bot got something wrong, please open a new issue and let us know.

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Thank You!

Your contributions, large or small, make great projects like this possible. Thank you for taking the time to contribute.
