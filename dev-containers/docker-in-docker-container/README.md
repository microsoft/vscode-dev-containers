# Docker in Docker Container

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into your local Docker Desktop instance without affecting your dev container. This example illustrates how you can do this by running CLI commands and using the [Docker VS Code extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) right from inside your dev container.

Note that the included `dev-container.dockerfile` can be altered to work with Debian/Ubuntu container such as `node` or `python`. Simply `FROM` statement in the file. For example:

```
FROM node:8
```
