
# Development Containers

## Basics

A **Development Container**  is a locally running Docker container that comes with:
- a basic tool stack (Python, node, Go, etc.) and its prerequisites, e.g., `pylint` for Python.
- a set of VS Code extensions that matches the tool stack, for example, the Microsoft Python extension for Python.
- a version of Visual Studio Code that can run inside the container and that we refer to as **Visual Studio Code Headless**.

When working with Development Containers you open a folder from the (local) file system and run it inside the container. Visual Studio Code  transparently connects to the container or more specifically to the Visual Studio Code Headless component that runs inside the container. To enable a folder to be used as a development folder all you need to add are some configuration files that provide VS Code with the information for how to provision a container.

## Getting started

### Installation

To start with Development Containers you need to:

- install [Docker](https://www.docker.com)
- install [code-wsl](https://builds.code.visualstudio.com/builds/wsl). This version of VS Code has support for running VS Code Headless and supports running VS Code headless inside WSL as well as running VS Code in Development Containers. Install the version that has the checkbox in the `Released` column checked.
- `git clone https://github.com/Microsoft/vscode-dev-containers.git`. This repository contains folders that are set up as development containers for different tool stacks.

To get insight into the running Docker containers it is recommended to install the [Docker extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker).

### Opening a folder in a Development Container

You are now ready to open a folder in a container:

- Start `code-wsl`.
- Open a folder in a Development Container by running the command **Dev Container: Open Folder in Container...** from the command palette.
- Select the folder with the tool stack you want to try out.

Once the container is provisioned a version of VS Code is started that is connected to the container. You can recognize this by the green status bar item that is shown in the bottom left corner.

For a quick tour refer to the [smoke test](https://github.com/Microsoft/vscode-remote/issues/216).

## Setting up a Folder as Development Container

You can use Development Containers for different scenarios:

- **Image**: you are working on an application/service that is deployed on Linux. You are **not** using Docker for deployment and are not familiar with Docker. Using a Development Container allows you to develop against the libraries that are used for deployment and you have parity between what is used for development and what is used in production. For example, you want to develop on macOS or Windows but you deploy to Linux in production.
- **Docker** supports two Docker setups:
  - **Dockerfile**: you are working on a single service that can be described by a single `Dockerfile`
  - **docker-compose**: you are working on services that are described using a `docker-compose-file.yml`.

In all of the above cases you can tag a folder as a Development Container by adding a file `.vscode/devContainer.json` to the folder. This file describes how to open the folder in a Development Container. This file can be considered the "recipe for creating a container". 

### Image

For this setup the `.vscode/devContainer.json` defines the following attributes:
- `image`: the image with the runtime and tools that should be used to provision the Development Container. The VS Code and partner teams will make images for different stacks available.
- `appPort`: an application port that is opened by the container, that is, when the container supports running a server that is listening at a particular port.
- `extensions`: a set of extensions (given as an array of extension IDs) that should be installed into the container. .

For example:

```json
{
	"image": "microsoft/dotnet:sdk",
	"appPort": 8090,
	"extensions": [
		"ms-vscode.csharp"
	]
}
```

### Dockerfile

For this setup the `.vscode/devContainer.json` defines the following attributes:
- `dockerFile`: the location of the Dockerfile that defines the contents of the container. The path is relative to the root of the workspace. This [page](doc/dev-container-dockerfile.md) provides more information for how to create a Dockerfile for a Development Container.
- `appPort`: an application port that is opened by the container, that is, when the container supports running a server that is listening at a particular port.
- `extensions`: a set of extensions (given as an array of extension IDs) that should be installed into the container. .

For example:

```json
{
	"dockerFile": "dev-container.dockerfile",
	"appPort": 8090,
	"extensions": [
		"dbaeumer.vscode-eslint"
	]
}
```

The advanced attribute `runArgs` can be used to define additional arguments that should be used when running the container. The example below uses `runArgs` to change the security policy to enable the ptrace system call for Go development container:
```json
{
	"dockerFile": "dev-container.dockerfile",
	"extensions": [
		"ms-vscode.go"
	],
	"runArgs": ["--cap-add=SYS_PTRACE", "--security-opt", "seccomp=unconfined"]
}
```

When you open a folder in this setup, then this will create a Docker container and start it immediately. You can use the [docker extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) to observe the running container. The container is stopped when the VS Code window showing the development container is closed. Since the version of VS Code Headless and VS Code need to match, the container is reconstructed whenever the version of VS Code changes.

### Docker Compose

This section describes the setup steps when you are using `docker-compose` to run multiple containers together. 

The following `docker-compose.yml` file defines a web service implemented in python that uses a redis service to persist some state:
```yaml
version: '3'
services:
  web:
    build: .
    ports:
     - "5000:5000"
  redis:
    image: "redis:alpine"
```

This is the `Dockerfile` for the `web` service:
```Dockerfile
FROM python:3
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```


Assume that you want to work on the _web service_ in a container. First you want to create a `dev-container.dockerfile` to create a container for the service for development. For develpment you want to have `pylint` installed into the container:

```Dockerfile
FROM python:3
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
RUN pip install pylint
CMD ["python", "app.py"]
```

With that in place we can now create a `docker-compose.develop.yml` that will be used when developing on the `web` service implemented in python. In this file you make the following modifications to enable running VS Code against a container:
- build the development container for the web service instead of the normale container defined in the `Dockerfile`.
- open an additional port so that VS Code can connect to its backend running inside the container. The VS Code headless server listens on port 8000 inside the container.
- mount the code of the service as a volume so that the source you work on is persisted on the local file system.
- overwrite the command that is run in the container so that the container is kept running. This is done so that you can develop on the python server and restart it after you made change. Also, if you want to debug the server you can launch the server under the debugger.

This results in the following `docker-compose.develop.yml`:
```yaml
version: '3'
services:
  web:
    build: 
      context: .    # build development container
      dockerfile: dev-container.dockerfile
    ports:
     - "5000:5000"
     - "8000:8000"  # open port to connect to VS Code headless
    volumes:
      - .:/app      # volume share the code
    command: sleep infinity # keep the container running
  redis:
    image: "redis:alpine"
```


Next you must create a development container description file `devContainer.json` in the `.vscode` folder with the following attributes:
- `dockerComposeFile` the name of the docker-compose file used to start the services.
- `service` the service you want to work on.
- `volume` the source volume mounted in the container.
- `devPort` the port VS Code can use to connect to its backend (8000 in the example above).
- `extensions` the list of extensions that must be installed into the container.

Here is an example:
```json
{
    "dockerComposeFile": "docker-compose.develop.yml",
    "service": "web",
    "volume": "app",
    "devPort": "8000",
	  "extensions": [
		  "ms-python.python"
	]
}
```

To develop the service run the command **Dev Container: Open Folder in Container...** and select the workspace you want to open. You can start the services from the command line using `docker-compose -f docker-compose.develop.yml up`. If the service is not running, then the action will start the services using `docker-compose -f docker-compose.develop.yml up`. Once the service is up, VS Code will inject the VS Code headless backend into the container and install the recommended extensions.

#### Docker-Compose-Samples
For complete setups refer to the following samples:
- [node](https://github.com/Microsoft/vscode-dev-containers/tree/master/docker-compose-tests/node) a simple setup with a single service implemented in node.
- [python-redis](https://github.com/Microsoft/vscode-dev-containers/tree/master/docker-compose-tests/python-redis) a setup with a redis service and a python web service  

**Please Note:** This injection will happen whenever a container is created. Therefore, when you want to continue development on the container use `docker-compose stop` to stop but not destroy the containers. In this way the VS Code backend and the extensions do not need to be installed on the next start.

**Known Limitations:**:
- The injection uses `apt get` which is not available in alpine images.
- The app is started in the web container without debugging support, therefore it isn't working

**Please Note:** This injection will happen whenever a container is created. Therefore, when you want to continue development on the container use `docker-compose stop` to stop but not destroy the containers. In this way the VS Code backend and the extensions do not need to be installed on the next start.

## Creating the Configuration Files
The command **Dev Container: Create Configuration File...** helps you to create the configuration files for a folder. The command will prompt you for the runtime you want to use in the container and then asks whether the container should expose a port for the application. 

## Managing Extensions

In the Development Container setup extensions can be run either inside the Development Container or locally in VS Code. VS Code infers the location where to run the extension based on some extension characteristics. Currently we distinguish the following two:

- **UI Extensions** make contributions to the UI only, do not access files in a workspace, and consequently can run locally. Examples for UI extensions are themes, snippets, language grammars, keymaps.
- **Workspace Extensions** these extensions access the files inside a workspace and they therefore must run inside the Development Container. A typical example of a Workspace extension is an extension that provides language features like Intellisense and operates on the files of the Workspace. 

When you install an extension manually, then VS Code and installs the extension in the appropriate location. 

### "Always-in-Container-Installed" Extensions

There are extensions that you would like to always have installed in a container for your personal productivity. A good example for this is the `GitLens` extension. You can define a set of extensions that will always be installed in a container using the setting `devcontainer.extensions`. For example:

```json
    "devcontainer.extensions": [
        "eamodio.gitlens"
    ]
```

## Extension Authors

As an extension author you should test your extension in the Development Container setup. We are considering to add a new tag for extensions so that they can declare whether they have been tested in the Development Container setup.

Sometimes VS Code's heuristic for determining the execution location automatically might fail. In this situation an extension author can overrule what VS Code infers with the attribute `uiExtension`. The attribute can be either `true` or `false`. When you make use of this setting, then ensure that your extension does not access the workspace contents. Since the workspace will not be available when an extension is run locally.
**Notice** the name of the attribute has not been finalized yet. 

Use the command **Developer: Show Running Extensions** to see where an extension is running.

### Testing Your Extension in the Development Container Setup

To test a version of your extension in the Development Container setup you can package the extension as a `VSIX` that you then install when a Development Container is running:

- use `vsce package` to package your extension as a VSIX
- use the **Install from VSIX...** available in the Extension Viewlets `...` menu to install the extension.

### Debugging your Extension (**TBD**)

### Reporting Issues

When reporting issues please file them against the https://github.com/Microsoft/vscode-remote/issues repository.
