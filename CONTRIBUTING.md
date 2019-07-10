# Contributing

This document outlines a number of ways you can get involved.

## Contributing Dev Container Definitions

This repository contains a set of **dev container definitions** to help get you up and running with a containerized environment. The definitions describe the appropriate container image, runtime arguments for starting the container, and VS Code extensions that should be installed. They are intended to be dropped into an existing project or folder rather than acting as sample projects. (See the [vscode-remote-try-*](https://github.com/search?q=org%3Amicrosoft+vscode-remote-try-&type=Repositories) repositories if you are looking for sample projects.)  

Have a container set up you're proud of and would like to share? Want to see some changes made to an existing definition? We love contributions! Read on to learn how.

### What makes a good Dev Container Definition?

A good definition in this repository will:

- Solve a common setup or installation challenge
- Illustrate a unique container runtime configuration
- Highlight an important tip or trick
- Or provide an easy to understand template for devlopers that are just getting started with dev containers. 

Since devcontainer.json can be commited to a source code repository, the definitions here are not intended to cover every possible permutation. When thinking about contributing a new dev container definition, consider the following questions:

1. How different is the scenario you are interested in from other dev container definitions in the repository? 
    - Does it drive significantly different extension, runtime, configuration requirements? 
    - Are the requirements cumbersome install or are they typically things added by a package manager (pip, npm, etc) using an project's manifest file (`package.json`, `requirements.txt`, etc)?
2. How likely are other developers to find the definition useful on its own? Could the scenario be broaded to help more people?

If the definition is too similar others, consider contributing a PR to improve an existing one instead. If the scenario is too specific consider generalizing it and making it more broadly applicable.

### Anatomy of a Dev Container Definition

The contents of the folders in the `containers` directory ultimately populate the available definitions list shown in the **Remote-Containers: Add Development Container Configuration Files...** command. To make this work, each folder consists of up to three things:

1. **The container definition itself** - These are the files and folders that will be added to a user's existing project / folder if they select the definition. Typically these files are stored in a `.devcontainer` folder.
2. **Test assets** - While you are creating your definition, you may need to use a test project to make sure it works as expected. Contributing these files back will also help others that want to contribute to your definition in the future. These files are typically located in a `test-project` folder.
3. **A `.npmignore` file** - This tells VS Code which files in the folder should be ignored when a user selects it for their project / folder. The file typically lists test assets or folders.

### Creating a new definition

Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.


To create a new definition:

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

    Finally, create a `README.md` in the folder with a brief description of the purpose of the container definition and any manual steps required to use it.

4. Update [`.npmignore`](https://docs.npmjs.com/misc/developers#keeping-files-out-of-your-package) if you've added new folders that should be excluded if used. Add anything you don't want copied in to a user's existing project / folder into this file in [glob](https://facelessuser.github.io/wcmatch/glob/) form.

### Developing and testing a definition

VS Code Remote provides a straight forward development loop for creating and editing container definitions. Just follow these steps to get started:

1. Create a definition folder and open it in VS Code
2. Edit the contents of the definition
3. Try it with `kbstyle(F1)` > **Remote-Containers: Reopen Folder in Container**.
4. On failure:
   1. `kbstyle(F1)` > **Remote-Containers: Reopen Folder Locally**, which will open a new local window.
   2. In this local window: Edit the contents of the `.devcontainer` folder as required.
   3. Try it again: Go back to the container window, `kbstyle(F1)` > **Developer: Reload Window**.
   4. Repeat as needed.
5. If the build was successful, but you want to make more changes:
      1. Edit the contents of the `.devcontainer` folder as required when connected to the container.
      2. `kbstyle(F1)` > **Remote-Containers: Rebuild Container**.
      3. On failure: Follow the same workflow above.

Note that if you make major changes, Docker may occasionally not pick up your edits. If this happens, you can delete the existing container and image, open the folder locally, and go to step 2 above. Install the [Docker extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) locally (when not in a container) to make this easy

After you get your container up and running, you can test it by adding test assets / projects into the definition folder and then adding their locations to the `.npmignore` file in [glob](https://facelessuser.github.io/wcmatch/glob/) form relative to the root of the folder. By convention, most definitions place test assets in a `test-project` folder and this path is referenced in the template `.npmignore` files.

Finally, commit your changes and submit a PR - we'll take a look at it, provide any needed feedback, and then merge it in. We appreciate any and all feedback!

### Speeding up container provisioning

While using a `Dockerfile` is a convenient way to get going with a new container definition, this method can slow down the process of creating the dev container since it requires the image be built by anyone using it.  If your definition is stable, we strongly recommend building and publishing your image to [DockerHub](https://hub.docker.com) or [Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry/) instead. 

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
