# Docker in Docker

## Summary

*Create child containers _inside_ a container, independent from the host's docker instance. Installs Docker extension in the container along with needed CLIs.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | GitHub Codespaces Team |
| *Definition type* | Dockerfile |
| *Works in Codespaces* | Yes |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian (though Ubuntu could be used instead) |
| *Languages, platforms* | Any |


## Description

Dev containers can be useful for all types of applications including those that also deploy into a container based-environment. While you can directly build and run the application inside the dev container you create, you may also want to test it by deploying a built container image into your local Docker Desktop instance without affecting your dev container.

In many cases, the best approach to solve this problem is by bind mounting the docker socket, as demonstrated in [containers/docker-from-docker](containers/docker-from-docker).  This definition demonstrates an alternative technique called "Docker in Docker".

This definition's approach creates pure "child" containers by hosting its own instance of the docker daemon inside this container.  This is compared to the forementioned "docker-_from_-docker" method that bind mounts the host's docker socket, creating "sibling" containers to the current container.

Running "Docker in Docker" requires the parent container to be run as `--privileged`.  This definition creates a `/usr/local/share/docker-init.sh` ENTRYPOINT script that,spawns the `dockerd` process.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
