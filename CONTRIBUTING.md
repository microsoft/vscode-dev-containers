# Contributing

This document outlines a number of ways you can get involved.

- [Contributing](#contributing)
  - [Contributing Dev Container Definitions](#contributing-dev-container-definitions)
    - [What makes a good Dev Container Definition?](#what-makes-a-good-dev-container-definition)
    - [A note on referenced images and Dockerfile contents](#a-note-on-referenced-images-and-dockerfile-contents)
    - [Expectations for new definitions](#expectations-for-new-definitions)
    - [Anatomy of a Dev Container Definition](#anatomy-of-a-dev-container-definition)
    - [Creating a new definition](#creating-a-new-definition)
    - [Why do Dockerfiles in this repository use RUN statements with commands separated by &&?](#why-do-dockerfiles-in-this-repository-use-run-statements-with-commands-separated-by-)
    - [Developing and testing a definition](#developing-and-testing-a-definition)
    - [Adding a Database Definition to an existing Container](#adding-a-database-definition-to-an-existing-container)
    - [Release cadence for new containers or container updates](#release-cadence-for-new-containers-or-container-updates)
  - [Contributing to Documentation](#contributing-to-documentation)
  - [Reporting Issues](#reporting-issues)
    - [Identify Where to Report](#identify-where-to-report)
    - [Look For an Existing Issue](#look-for-an-existing-issue)
    - [Writing Good Bug Reports and Feature Requests](#writing-good-bug-reports-and-feature-requests)
    - [Final Checklist](#final-checklist)
    - [Follow Your Issue](#follow-your-issue)
    - [Automated Issue Management](#automated-issue-management)
  - [Code of Conduct](#code-of-conduct)
  - [Thank You!](#thank-you)

## Contributing Dev Container Definitions

This repository contains a set of **dev container definitions** to help get you up and running with a containerized environment. The definitions describe the appropriate container image, runtime arguments for starting the container, and VS Code extensions that should be installed. They are intended to be dropped into an existing project or folder rather than acting as sample projects. (See the [vscode-remote-try-*](https://github.com/search?q=org%3Amicrosoft+vscode-remote-try-&type=Repositories) repositories if you are looking for sample projects.)  

Have a container set up you're proud of and would like to share? Want to see some changes made to an existing definition? We love contributions! Read on to learn how.

### What makes a good Dev Container Definition?

A good definition in this repository will:

- Solve a common setup or installation challenge
- Illustrate a unique container runtime configuration
- Highlight an important tip or trick
- Or provide an easy to understand template for developers that are just getting started with dev containers. 
- Works on Linux, macOS, and Windows

Since devcontainer.json can be commited to a source code repository, the definitions here are not intended to cover every possible permutation. When thinking about contributing a new dev container definition, consider the following questions:

1. How different is the scenario you are interested in from other dev container definitions in the repository? 
    - Does it drive significantly different extension, runtime, configuration requirements? 
    - Are the requirements cumbersome to install or are they typically things added by a package manager (pip, npm, etc) using a project's manifest file (`package.json`, `requirements.txt`, etc)?
2. How likely are other developers to find the definition useful on its own? Could the scenario be broadened to help more people?

If the definition is too similar to others, consider contributing a PR to improve an existing one instead. If the scenario is too specific consider generalizing it and making it more broadly applicable.

To help speed up PRs, we encourage you to install the recommended [EditorConfig extension](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig). This will ensure your changes adhere to our style guidelines.

### A note on referenced images and Dockerfile contents

One of the things we want to be sure anyone using a definition from this repository is able to do is understand what is inside it. In general, images referenced  by Dockerfiles, Docker Compose files, or devcontainer.json in this repository should reference known base Docker, Microsoft, or runtime/platform community/vendor managed base images. These images are already well maintained, regularly patched, and maintained by the platform/runtime community or vendor. From there you can use a Dockerfile to add any additional contents.

When adding contents to the Dockerfile, use official sources. There are a number of pre-built images you can take advantage of to speed things up for yourself and other developers to reduce build times. In particular, take note of images like `mcr.microsoft.com/vscode/devcontainers/base:debian` and `mcr.microsoft.com/vscode/devcontainers/base:ubuntu` ([see here for a list](https://hub.docker.com/_/microsoft-vscode-devcontainers)). These are like the base `debian` and `ubuntu` images but include things developers commonly need or want (e.g. git and curl).

If you are using something like `curl` or `wget` to download the contents, add a checksum verification if one is available. Using package managers like `apt-get` on Debian/Ubuntu with 3rd party sources can also be a way to do this verification since they require adding the source's signing key.

Note that other definitions in this repository use Debian or Ubuntu bases in the vast majority of cases. We recommend using this as the variation of the base image you use wherever possible so you can avoid questions from developers new to working with Linux.

### Expectations for new definitions

When contributing a new definition, be sure you are also willing to sign up to maintain the definition over time. The likelihood of other maintainers in this repository having the needed knowledge properly maintain your definition is low, so you'll be contacted about PRs and issues raised about them. Please include your GitHub alias (and if desired other contact info) in the README so that you are identified as the maintainer of the definition. You will "@'d" in on PRs and issues raised pertaining to the definition.

Over time, if you no longer want to maintain the definition and do not have a suitable replacement, we can remove it from the repository. Just raise an issue or PR and let us know. This repository's maintainers may also need to do this proactively if an issue is raised that is breaking and we are unable to get a timely response in resolving the issue.

### Anatomy of a Dev Container Definition

The contents of the folders in the `containers` directory ultimately populate the available definitions list shown in the **Remote-Containers: Add Development Container Configuration Files...** command. To make this work, each folder consists of up to three elements:

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

    Note that any additional assets can be included as needed, but keep in mind that these will overlay on top of an existing project. Keeping these files in the `.devcontainer` folder should reduce the chances of something conflicting but note that any commands that are run are relative to the root of the project, so you'll need to include `.devcontainer` in any path references.

    Finally, create a `README.md` in the folder with a brief description of the purpose of the container definition and any manual steps required to use it.

4. Update [`.npmignore`](https://docs.npmjs.com/misc/developers#keeping-files-out-of-your-package) if you've added new folders that should be excluded if used. Add anything you don't want copied in to a user's existing project / folder into this file in [glob](https://facelessuser.github.io/wcmatch/glob/) form.

### Why do Dockerfiles in this repository use RUN statements with commands separated by &&?

Each `RUN` statement creates a Docker image "layer". If one `RUN` statement adds in temporary contents, these contents remain in this layer in the image even if they are deleted in a subsequent `RUN`. This means the image takes more storage locally and results in slower image download times if you publish the image to a registry.

So, in short, you want to clean up after you install or configure anything in the same `RUN` statement. To do this, you can either:

1. Use a string of commands that cleans up at the end. e.g.: 

    ```Dockerfile
    RUN apt-get update && apt-get -y install --no-install-recommends git && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

    ```

    ... or across multiple lines (note the `\` at the end escaping the newline):

    ```Dockerfile
    RUN apt-get update \
        && apt-get -y install git \
        && apt-get autoremove -y \
        && apt-get clean -y \
        && rm -rf /var/lib/apt/lists/*
    ```

2. Put the commands in a script, temporarily copy it into the container, then remove it. e.g.:

    ```Dockerfile
    COPY ./my-script.sh /tmp/my-script.sh
    RUN bash /tmp/my-script.sh \
        && rm -f /tmp/my-script.sh
    ```

Some other tips:

1. You'd be surprised [how big package lists](https://askubuntu.com/questions/179955/var-lib-apt-lists-is-huge) can get, so be sure to clean these up too. Most Docker images that use Debian / Ubuntu use the following command to clean these up:

    ```
    rm -rf /var/lib/apt/lists/*
    ```

    The only downside of doing this is that `apt-get update` has to be executed before you install a package. However, in most cases adding this package to a Dockerfile is a better choice anyway since this will survive a "rebuild" of the image and the creation of an updated container. 

2. Use the scripts in the [script library](./script-library) in this repository where appropriate. You do not even need to copy the script into your `.devcontainer` folder to use it. See the [README](./script-library) for details. Most existing definitions use the "common" script to ensure things like `git`, a non-root user, and useful command line utilities like `ps`, `ip`, `jq` are present.

3. In all cases, you'll want to pay attention to package caching since this can also take up image space. Typically there is an option for a package manager to not cache when installing that you can use to minimize the size of the image. For example, for Alpine Linux, there's `apk --no-cache`

4. Watch out for the installation of "recommended" packages you don't need. By default, Debian / Ubuntu's `apt-get` installs packages that are commonly used with the one you specified - which in many cases isn't required. You can use `apt-get -y install --no-install-recommends` to avoid this problem.

### Developing and testing a definition

VS Code Remote provides a straightforward development loop for creating and editing container definitions. Just follow these steps to get started:

1. Create a definition folder and open it in VS Code
2. Edit the contents of the definition
3. Try it with <kbd>F1</kbd> > **Remote-Containers: Reopen Folder in Container**.
4. On failure:
   1. <kbd>F1</kbd> > **Remote-Containers: Reopen Folder Locally**, which will open a new local window.
   2. In this local window: Edit the contents of the `.devcontainer` folder as required.
   3. Try it again: Go back to the container window, <kbd>F1</kbd> > **Developer: Reload Window**.
   4. Repeat as needed.
5. If the build was successful, but you want to make more changes:
      1. Edit the contents of the `.devcontainer` folder as required when connected to the container.
      2. <kbd>F1</kbd> > **Remote-Containers: Rebuild Container**.
      3. On failure: Follow the same workflow above.

Note that if you make major changes, Docker may occasionally not pick up your edits. If this happens, you can delete the existing container and image, open the folder locally, and go to step 2 above. Install the [Docker extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) locally (when not in a container) to make this easy.

After you get your container up and running, you can test it by adding test assets / projects into the definition folder and then adding their locations to the `.npmignore` file in [glob](https://facelessuser.github.io/wcmatch/glob/) form relative to the root of the folder. By convention, most definitions place test assets in a `test-project` folder and this path is referenced in the template `.npmignore` files.

Finally, commit your changes and submit a PR - we'll take a look at it, provide any needed feedback, and then merge it in. We appreciate any and all feedback!

### Adding a Database Definition to an existing Container

VS Code Dev Containers allow multiple containers to run together. This is useful, for example, when adding database support to an existing container, and can be leveraged with `docker compose.`

1. Create a new copy of an existing language definition folder, and hyphenate the database name.
   1. For example, `java` becomes `java-postgres`.
2. Create a new `docker-compose.yml` file.
   1. For both, the app and the database dev container, add the service `docker-compose.yml`. The database container typically is referenced by it's stadard image or by the `db` tag. The `app` container is the dev container that is defined via the Dockerfile definition.
   2. For more details on the sections in the docker-compose file see: https://github.com/compose-spec/compose-spec/blob/master/spec.md
   3. We recommend using a major stable version tag for the Database, as using `latest` is generally considered to be less secure and can introduce breaking bugs.
   4. It's common that containers will need to be connected through a network so that the `app` can connect to the `db`. This can normally be done by adding the following to the `app` definition:

    ```yaml
        network_mode: service:db
    ```

3. Modify the `devcontainer.json` with any launch options or VS Code specific `settings.json` options that may be needed. 
   1. For example, when working with a SQL database, it might be necessary to add the following:
   ```json
    "forwardPorts": [5000, 5432],    
    ```
    This allows the PostgreSQL database to be available on ports 5000 and 5432, allowing other containers and the host to connect to it. See the [Visual Studio devcontainer.json Reference](https://code.visualstudio.com/docs/remote/devcontainerjson-reference#_general-devcontainerjson-properties) for more information.
    2. It might be necessary to add additional VS Code Extensions to allow for an easier dev experience. This could be database dependent (`MSSQL`, `NoSQL`, etc.)
4. Modify the existing Tests or add new tests to ensure that the following scenarios are possible:
    1. The application can successfully ping the DB Container.
    2. The application can login to the DB Container using the default login data. 
    3. The application can send a query to the existing DB and receive data from the DB. (Typically listing the named databases is considered a valid test.)
5. Remove the following from your new container:
   1. The `history` folder
   2. The `'.devcontainer/base.Dockerfile` file
   3. The `'definition-manifest.json` file
6. Make changes to your `README.md` similar to the ones you see by comparing `/containers/java/README.md` with `/containers/java-postgres/README.md`

Finally, commit your changes and submit a PR - we'll take a look at it, provide any needed feedback, and then merge it in. We appreciate any and all feedback!

### Release cadence for new containers or container updates

The vscode-dev-containers repo is currently bundled with the VS Code Remote - Containers extension to ensure version compatibility. (There is a feature request to update the container list [out-of-band](https://github.com/microsoft/vscode-remote-release/issues/425), but this is not currently in place.)

Therefore, the release schedule for vscode-dev-containers is the same as the extension. The extension follows the same release cadence and schedule for **VS Code (stable)** as VS Code itself. 
* VS Code uses [four week iterations](https://github.com/microsoft/vscode/wiki/Development-Process#inside-an-iteration). 
* You can find the dates of the current iteration in a pinned issue in the [vscode repository](https://github.com/microsoft/vscode) and in-flight features for the extension itself in the [vscode-remote-release](https://github.com/microsoft/vscode-remote-release) repository.

The Remote - Containers extension ships into **VS Code Insiders** as new features land during the iteration. This is not currently an automated daily release like VS Code itself, so the exact timing during the iteration can vary. However, it will happen during endgame week at a minimum (week 4).

If there is an urgent need for an update to the definitions outside of this release cycle, please raise an issue in this repository requesting an out-of-band release to fix a critical issue.

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
