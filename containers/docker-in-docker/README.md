# Docker in Docker

## Summary

*Illustrates how you can use it to access your local Docker install from inside the a dev container by simply volume mounting the Docker unix socket.  This variation uses `runArgs` and a `Dockerfile` to do the volume mounting*

> **Note:** You can also check out the [Docker Compose](../docker-in-docker-compose) variation of this same definition.

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code team |
| *Definition type* | Dockerfile |
| *Languages, platforms* | Any |

## Description

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into your local Docker Desktop instance without affecting your dev container. This example illustrates how you can do this by running CLI commands and using the [Docker VS Code extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker) right from inside your dev container.

## Usage

No additional setup steps are required, but note that the included `dev-container.dockerfile` can be altered to work with other Debian/Ubuntu based-container images such as `node` or `python`. Simply update `FROM` statement in the file to change the starting image. For example:

```Dockerfile
FROM node:8
```

## How it works

The trick that makes this work is as follows:

1. Install the Docker CLI in the container. From `dev-container.dockerfile`:

    ```Dockerfile
    # Install Docker CE CLI
    RUN apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
        && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
        && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        && apt-get update \
        && apt-get install -y docker-ce-cli
    ```
2. Forward the Docker socket. From `devContainer.json`:

    ```json
    "runArgs": ["-v","/var/run/docker.sock:/var/run/docker.sock"]
    ```

That's it!