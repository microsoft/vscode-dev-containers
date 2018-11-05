# Defining a Development Container for a Tool Stack

This page describes how to define a Development Container for a particular tool stack. As an example we will define a Development Container for Java.

## Create the Development Container description file

A Development Container has a description file that describes how the container is populated including which containers should be installed. The container description file is located in the `.vscode` folder and is called `devContainer.json`.

In an empty folder create the description file:

`devContainer.json`
```json
{
	"dockerFile": "../dev-container.dockerfile",
	"extensions": [
		"vscjava.vscode-java-pack"
	]
}
```

- The attribute `dockerFile` refers to the Dockerfile that is used to populate the container.
- The attribute `extensions` defines the list of extensions that should be installed into the container. In this case we want to install the 'Java Extension Pack' into the container.

## Define the custom Dockerfile

We want to create a Development Container for Java where we use the `vscode-java` extensions that require Java 8 and Maven. We therefore look for an image that comes with Java 8 and the latest version of Maven. Fortunately there is are [Maven](https://hub.docker.com/_/maven/) images on dockerhub. We pick the slim image with Maven 3.5 and the JDK 8, which is tagged with `3.5-jdk-8-slim`.

This image does not come with git and we therefore install git into the development container.

`dev-Container.dockerfile`
```Dockerfile
FROM maven:3.5-jdk-8-slim

 # Install git
RUN apt-get update && apt-get -y install git \
  && rm -rf /var/lib/apt/lists/*
```

## Limitations

The current image constructions assumes that `apt` is available. This means 'alpine' images can currently not be used. We will eventually support different package managers.

## Example

Example development containers can be found in the [vscode-remote repository](https://github.com/Microsoft/vscode-remote/tree/remote-hackathon/remote/dev-containers).
