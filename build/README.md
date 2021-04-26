# Build and image generation for vscode-dev-containers

This folder contains scripts to build and push images into the Microsoft Container Registry (MCR) from this repository, generate or modify any associated content to use the built image, track dependencies, and create an npm package with the result that is shipped in the VS Code Remote - Containers extension.

## Build CLI

The Node.js based build CLI (`build/vsdc`) has commands to:

1. Build and push to a repository: `build/vsdc push`
2. Build, push, and npm package assets that are modified as described above: `build/vsdc package`
3. Generate cgmanifest.json: `build/vsdc cg`
4. Update all script source URLs in Dockerfiles to a tag or branch: `build/vsdc update-script-sources`

Run with the `--help` option to see inputs.

This CLI is used in the GitHub Actions workflows in this repository.

- `push-dev.yml`: Pushes a "dev" tag for each image to be generated in this repository and fires repository dispatch to trigger cgmanifest.json generation, and attaches an npm package with the definitions to the actions run.
- `push-and-package.yml`: Triggers when a release tag is pushed (`vX.Y.Z`). Builds and pushes a release version of the images, creates a release, and attaches an npm package with the definitions to the release. Note that this update the tag with source files that contain a SHA hash for script sources. You maay need to run `git fetch --tags --force` locally after it runs.
- `cgmanifest.yml`: Listens to the repository dispatch event to trigger cgmanifest.json generation.

## Setting up a container to be built

> **Note:** Only Microsoft VS Code team members can currently onboard an image to this process since it requires access the Microsoft Container Registry. [See here for details](https://github.com/microsoft/vscode-internalbacklog/wiki/Remote-Container-Images-MCR-Setup).
>
> However, if you have your own pre-built image or build process, you can simply reference it directly in you contributed container.

Image build/push to MCR is managed using config in `definition-manifest.json` files that are located in the container definition folder. The config lets you set dependencies between definitions and map actual image tags to multiple definitions. So, the steps to onboard an image are:

1. **Important:** Update any `ARG` values in your `Dockerfile` to reflect what you want in the image. Use boolean `ARGS` with `if` statements to skip installing certain things in the image.

    > **Note:** The `build.args` and `build.dockerfile` properties are **intentionally ignored** during image build so that you can vary image defaults and devcontainer.json defaults as appropriate. The only property considered is `build.context` since this may be required for the build to succeed.

2. Create [a `definition-manifest.json` file](#definition-manifestjson)

3. [Optional] Create a [stub Dockerfile](#creating-an-alternate-stub-dockerfile)

4. Update the `vscode` [config files for MCR](https://github.com/microsoft/vscode-internalbacklog/wiki/Remote-Container-Images-MCR-Setup) as appropriate (MS internal only).

## Testing the build

Once you have your build configuration setup, you can use the `vscdc` CLI to test that everything is configured as you would expect.

1. First, build the image(s) using the CLI as follows:

   ```bash
   build/vscdc push --no-push --registry mcr.microsoft.com --registry-path vscode/devcontainers --release master <you-definition-id-here>
   ```

2. Use the Docker CLI to verify all of the expected images and tags and have the right contents:

    ```bash
    docker run -it --rm mcr.microsoft.com/vscode/devcontainers/<expected-repository>:dev-<expected tag> bash
    ```

3. Finally, test cgmanifest generation by running:

   ```bash
   build/vscdc cg --registry mcr.microsoft.com --registry-path vscode/devcontainers --release master <you-definition-id-here>
   ```

Once you're happy with the result, you can also verify that the `devcontainer.json` and the associated concent that will be generated for your definition is correct.

1. Generate a `.tgz` with all of the definitions zipped inside of it.

    ```bash
    build/vscdc pack --prep-and-package-only --release master
    ```

    A new file called `vscode-dev-containers-<version>-dev.tgz` should be in the root of the repository once this is done.

2. Unzip generated the `tgz` somewhere in your filesystem.

3. Start VS Code and use  **Remote-Containers: Open Folder in Container...**  on the unzipped definition in the `package/containers` folder and verify everything starts correctly.

That's it!

## Creating an alternate "stub" Dockerfile

By default, the **Remote-Containers: Add Development Container Configuration File...** and related properties will use a basic getting started stub / sample Dockerfile [from here](./assets) and with a reference to the appropriate image. This provides some basic getting started information for developers.

However, in some cases you may want to include some special instructions for developers. In this case, you can add a custom stub Dockerfile by creating the following files:

- `base.Dockerfile`: Dockerfile used to generate the image itself
- `Dockerfile`: A stub Dockerfile

You can then reference `base.Dockerfile` in `devcontainer.json` to make editing the file that is used to create the image easy.

When the definitions are packaged up for use, `base.Dockerfile` is excluded and the `devcontainer.json` file is automatically updated to `Dockerfile`. Any comment links are also modified appropriately.

If you're using the [variants property](#the-variants-property) in `definition-manifest.json`, you can set up the custom stub so that you can specify the variant from `devcontainer.json` by adding an argument called `VARIANT` right before the `FROM` statement that uses it.

In your `Dockerfile`:

```Dockerfile
ARG VARIANT=3
FROM mcr.microsoft.com/vscode/devcontainers/python:${VARIANT}
```

In `devcontainer.json`:

```json
"build": {
    "args": {
        "VARIANT": "3.8"
    }
}
```

## definition-manifest.json

Let's run through the `definition-manifest.json` file.

### The build property

The `build` property defines how the definition maps to image tags and what type of "stub" should be used. Consider the Debian 9 [definition-manifest.json](../containers/debian-9-git/definition-manifest.json) file.

```json
"build": {
    "rootDistro": "debian",
    "latest": true,
    "tags": [
        "base:${VERSION}-debian-9",
        "base:${VERSION}-stretch"
    ]
}
```

The **`rootDistro`** property can be `debian`, `alpine`, or `redhat` currently. Ubuntu-based containers should use `debian`.

The **`latest`** and **`tags`** properties affect how tags are applied. For example, here is how several dev container folders map:

```text
debian => mcr.microsoft.com/vscode/devcontainers/base:debian
alpine => mcr.microsoft.com/vscode/devcontainers/base:alpine
ubnutu => mcr.microsoft.com/vscode/devcontainers/base:ubuntu
```

This results in just one "repository" in the registry much like you would see for other images in Docker Hub.

- mcr.microsoft.com/vscode/devcontainers/base

The package version is then automatically added to these various tags in the `${VERSION}` location for an item in the `tags` property array as a part of the release. For example, release 0.40.0 would result in:

- 0.40.0-debian-9
- 0.40-debian-9
- 0-debian-9
- debian-9 <= Equivalent of latest for debian-9 specifically
- 0.40.0-stretch
- 0.40-stretch
- 0-stretch
- stretch <= Equivalent of latest for stretch specifically

In this case, Debian is also the one that is used for `latest` for the `base` repository, so that tag gets applied too.  If you ran only the Alpine or Ubuntu versions, the latest tag would not update.

> **NOTE:** The version number used for this repository should be kept in sync with the VS Code Remote - Containers extension to make it easy for developers to find.

There's a special "dev" version that can be used to build master on CI - I ended up needing this to test and others would if they base an image off of one of the MCR images.  e.g. `dev-debian-9`.

Finally, there is a **`parent`** property that can be used to specify if the container depends an image created as a part of another container build. For example, `typescript-node` uses the image from `javascript-node` and therefore includes the following:

```json
"build" {
    "parent": "javascript-node"
}
```

### The definitionVersion property

While in most cases it makes sense to version the contents of a definition with the repository, there may be scenarios where you want to be able to version independantly. A good example of this [is the `vsonline-linux` defintion](../containers/vsonline-linux) where upstream edits could cause breaking changes in this image. Rather than increasing the major version of the extension and all defintions whenever this happens, the definition has its own version number.

When this is necessary, the `definitionVersion` property in the `definition-manifest.json` file can be set.

```json
"definitionVersion": "0.1.0"
```

### The variants property

In many cases, you will only need to create one image per dev container definition. Even if there is only one or two versions of a given runtime available at a given time, it can be useful to simply have different definitions to aid discoverability.

In other cases, you may want to generate multiple images from the same definition but with one small change. This is where the variants property comes in. Consider this `definition-manifest.json`:

```json
"build": {
    "rootDistro": "debian",
    "tags": [
        "python:${VERSION}-${VARIANT}"
    ],
    "variants": [ "3", "3.6", "3.7", "3.8" ]
}
```

The **left-most** item in the list is the one that will have the `latest` tag applied if applicable.

And in its corresponding Dockerfile:

```Dockerfile
ARG VARIANT=3
FROM python:${VARIANT}
```

> **Note:** You may want to customize the "stub" Dockerfile that is actually used by developers rather than using the default one.  [See below for details](#creating-an-alternate-stub-dockerfile).

This configuration would cause separate image variants, each with a different `VARIANT` build argument value passed in, that are then tagged as follows:

- mcr.microsoft.com/vscode/devcontainers/python:3
- mcr.microsoft.com/vscode/devcontainers/python:3.6
- mcr.microsoft.com/vscode/devcontainers/python:3.7
- mcr.microsoft.com/vscode/devcontainers/python:3.8

In addition `mcr.microsoft.com/vscode/devcontainers/python` would point to `mcr.microsoft.com/vscode/devcontainers/python:3` since it is the first in the list.

### The dependencies property

The dependencies property is used for dependency and version tracking. Consider the Debian 9 [definition-manifest.json](../containers/debian-9-git/definition-manifest.json) file.

```json
"dependencies": {
    "image": "debian:9",
    "imageLink": "https://hub.docker.com/_/debian",
    "debian": [
        "apt-utils",
        "..."
    ],
    "manual": [
        {
            "Component": {
                "Type": "git",
                "git": {
                    "Name": "Oh My Zsh!",
                    "repositoryUrl": "https://github.com/robbyrussell/oh-my-zsh",
                    "commitHash": "c130aadb6a66aa680a322c08d87ad773316f713d"
                }
            }
        }
    ]
}
```

The **`image`** property is the actual base Docker image either in Docker Hub or MCR. **`imageLink`** is then the link to a dscription of the image.

Following this is a list of libraries installed in the image by its Dockerfile. The following package types are currently supported:

- `debian` - Debian packages (apt-get)
- `ubuntu` - Ubuntu packages (apt-get)
- `alpine` - Alpine Linux packages (apk)
- `pip` - Python pip packages
- `pipx` - Python utilities installed using pipx
- `npm` - npmjs.com packages installed using npm or yarn
- `manual` - Useful for other types of registrations that do not have a specific type, like `git` in the example above.

For everything but `manual`, the image that is generated is started so the package versions can be queried automatically.

---

## Build process details and background

Currently the vscode-dev-containers repo contains pure Dockerfiles that need to be built when used. While this works well from the perspective of providing samples, some of the images install a significant number of runtimes or tools which can take a long time to build.

We can resolve this by pre-building some of these images, but in-so-doing we want to make sure we:

1. Ensure vscode-dev-containers continues to be a good source of samples
2. Improve the performance using the most popular (or in some cases slowest to build) container images
3. Make it easy for users to add additional software to the images
4. Make it easy for contributors to build, customize, and contribute new definitions

We won't be able to build all images in the repository or publish them under a Microsoft registry, but we would want to allow contributors to build their own images for contributions if they wanted to do so by keeping the ability to use a stand alone Dockerfile, image reference, or docker-compose file like today.

In order to meet the above requirements, this first phase keeps the way the dev containers deployed as it is now - an npm package. Future phases could introduce a formal registry, but this is overkill current state.

### Versioning

At this phase, versioning of the image can be tied to the release of the npm package. For example, as of this writing, the current version is 0.35.0. All images that are generated would then inherit this version.

We would follow semver rules for bumping up the repository name - any fix that needs to be deployed immediately would be "fix" level semver bump. When released as latest, the image would be tagged as is done in other Docker images. Using the 0.35.0 example, new images would be tagged as:

- 0
- 0.35
- 0.35.0
- latest

In the unlikely event a break fix needed to be deployed and not tagged latest, we would have a facility to tag as follows:

- 0.35
- 0.35.0

This has a few advantages:

1. Tags are generated for each version of the repository that is cut. This allows us to refer directly to the exact version of the source code used to build the container image to avoid confusion. e.g. `https://github.com/microsoft/vscode-dev-containers/tree/v0.35.0/containers/javascript-node-8`
2. Similarly, as containers are deprecated and removed from the repository, you can still refer back to the container source and README.
3. Upstream changes that break existing images can be handled as needed.
4. Developers can opt to use the image tag 0.35 to get the latest break fix version if desired or 0 to always get the latest non-breaking update.

When necessary, a specific version can also be specified for an individual image using a `definitionVersion` property, but this is generally the exception.

### Deprecation of container definitions

The versioning scheme above allows us to version dev containers and reference them even when they are removed from `master`. To keep the number of containers in `master` reasonable, we would deprecate and remove containers under the following scenarios:

1. It refers to a runtime that is no longer supported - e.g. Node.js 8 is out of support as of the end of 2019, so we would deprecate `javascript-node-8`. Until that point, we would have containers for node 8, 10, and 12 (which just went LTS).
2. The container is not used enough to maintain and has broken.
3. The container refers to a product that has been deprecated.
4. The container was contributed by a 3rd party, has issues, and the 3rd party is not responsive.

Since the images would continue to exist after this point and the source code is available under the version label, we can safely remove the containers from master without impacting customers.

### Release process and the contents of the npm package

When a release is cut, there are a few things that need to happen. One is obviously releasing the appropriate image. However, to continue to help customers understand how to customize their images, we would want to reference a user modifiable "stub" Dockerfile instead of an image directly. This also is important to help deal with shortcomings and workarounds that require something like specifying a build argument. For example:

```Dockerfile
FROM mcr.microsoft.com/vscode/devcontainer/javascript-node:0-10

# ** [Optional] Uncomment this section to install additional packages. **
#
# RUN apt-get update \
#    && export DEBIAN_FRONTEND=noninteractive \
#    && apt-get -y install --no-install-recommends <your-package-list-here>
```

This retains its value as a sample but minimizes the number of actual build steps. This template can evolve over time as new features are added Referencing The MAJOR version of the image in this Dockerfile allows us to push fixes or upstream updates that do not materially change the definition without developers having to change their projects.

#### Repository contents

Consequently, this user stub Dockerfile needs to be versioned with the `devcontainer.json` file and can technically version independently of the actual main Dockerfile and image. Given this tie, it makes sense to keep this file with `devcontainer.json` in the repository. The repository therefore would could contain:

```text
📁 .devcontainer
     📄 base.Dockerfile
     📄 devcontainer.json
     📄 Dockerfile
📁 test-project
📄 definition-manifest.json
📄 README.md
```

The `definition-manifest.json` file dictates how the build process should behave as [dscribed above](#setting-up-a-container-to-be-built). In this case, `devcontainer.json` points to `base.Dockerfile`, but this is the Dockerfile used to generate the actual image rather than the stub Dockerfile. The stub that references the image is in `base.Dockerfile`.  To make things easy, we can also automatically generate this stub at release time if only a Dockerfile is present. If no `base.Dockerfile` is found, the build process falls back to using `Dockerfile`.

Testing, then, is as simple as it is now - open the folder in `vscode-dev-containers` in a container and edit / test as required. Anyone simply copying the folder contents then gets a fully working version of the container even if in-flight and there is no image for it yet.

In the vscode-dev-containers repo itself, the `FROM` statement in `Dockerfile` would always point to `latest` or `dev` since it what is in master may not have even been released yet. This would get dynamically updated as a part of the release process - which we will cover next.

```Dockerfile
FROM mcr.microsoft.com/vs/devcontainer/javascript-node:dev-10
```

##### Automated updates of other Dockerfiles

The process also automatically swaps out referenced MCR images for MAJOR versions of built images in any Dockerfile that is added to the package. This allows us to push break fix and or security patches as break fix releases and people will get them. The build supports an option to not update `latest` and MAJOR versions, so we can also rev old MAJOR versions if we have to, but normally we'd roll forward instead.

##### Common scripts

Another problem the build solves is mass updates - there's a set of things we want in every image and right now it requires ~54 changes to add things. With this new process, images use a tagged version of scripts in `script-library`. The build generates a SHA for script so they can be safely used in Dockerfiles that are not built into images while still allowing people to just grab `.devcontainer` from master and use it if they prefer.

When a release is cut, this SHA is generated and the source code for the related Git tag is updated to include source files with these values set. Consequently, you may need to run `git fetch --tags --force` to update a tag that already exists on your system.

#### Release process

When a release is cut, the contents of vscode-dev-containers repo are staged. The build process then does the following for the appropriate dev containers:

1. Build an image using the `base.Dockerfile` and push it to a container registry with the appropriate version tags. If no `base.Dockerfile` is found, `Dockerfile` is used instead.  If the `variants` property is set, one image is built per variant, with the variant value being passed in as the `VARIANT` build argument.

2. After the image is built and pushed, `base.Dockerfile` is deleted from staging if present. If no `base.Dockerrfile`, a `Dockerfile` is replaced with stub is used based on the configured rootDistro in `definition-manifest.json` (Alpine vs Debian).

3. Next, `Dockerfile` is updated to point to the correct MAJOR version and a link is added to the Dockerfile used to build the referenced image.

    ```Dockerfile
    # For information on the contents of the image referenced below, see the Dockerfile at
    # https://github.com/microsoft/vscode-dev-containers/tree/v0.35.0/containers/javascript-node-10/.devcontainer/base.Dockerfile
    FROM mcr.microsoft.com/vscode/devcontainer/javascript-node:0-10
    ```

    This also works when the `VARIANT` ARG is used. The MAJOR part of the release version is placed in front of the argument in the FROM statement:

    ```Dockerfile
    ARG VARIANT="3"
    FROM mcr.microsoft.com/vscode/devcontainer/python:0-${VARIANT}
    ```

4. `devcontainer.json` is updated to point to `Dockerfile` instead of `base.Dockerfile` (if required) and a comment is added that points to the definition in this repository (along with its associated README for this specific version).

    ```json
    // For format details, see https://aka.ms/vscode-remote/devcontainer.json or the definition README at
    // https://github.com/microsoft/vscode-dev-containers/tree/v0.35.0/containers/javascript-node-10
    {
        "name": "Node.js 10",
        "dockerFile": "Dockerfile",
        "extensions": [
            "dbaeumer.vscode-eslint"
        ]
    }
    ```

After everything builds successfully, the packaging process kicks off and performs the following:

1. Runs through all Dockerfiles in the `containers` folder and makes sure any references to `mcr.microsoft.com/vscode/devcontainers` in other non-built dockerfiles reference the MAJOR version as described in step 3 above.

2. Runs through all Dockerfiles and looks for [common script](#common-scripts) references and updates the URL to the tagged version and adds the expected SHA as another arg. The result is that sections of the Dockerfile that look like this:

    ```Dockerfile
    ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/common-debian.sh"
    ARG COMMON_SCRIPT_SHA="dev-mode"
    ```

    are transformed into this:

    ```Dockerfile
    ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.112.0/script-library/common-debian.sh"
    ARG COMMON_SCRIPT_SHA="28e3d552a08e0d82935ad7335837f354809bec9856a3e0c2855f17bfe3a19523"
    ```

    so that it sections later in the Dockerfile anchors to a specific version of the script and can verify the script SHA before running it:

    ```Dockerfile
    RUN curl -sSL  $COMMON_SCRIPT_SOURCE -o /tmp/common-setup.sh\
        && if [ "$COMMON_SCRIPT_SHA" != "dev-mode" ]; then echo "$COMMON_SCRIPT_SHA /tmp/common-setup.sh" | sha256sum -c - ; fi \
        && /bin/bash /tmp/common-setup.sh "$INSTALL_ZSH" "$USERNAME" "$USER_UID" "$USER_GID" \
        && rm /tmp/common-setup.sh
    ```

3. These modified contents are then archived in an npm package exactly as they are today and shipped with the extension (and over time we could dynamically update this between extension releases).

```text
📁 .devcontainer
     📄 devcontainer.json
     📄 Dockerfile
```
