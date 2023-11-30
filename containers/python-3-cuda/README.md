# Python 3 & CUDA

## Summary

*Develop applications with Python 3 and CUDA Support*

| Metadata | Value |
|----------|-------|
| *Contributors* | [twsl](https://github.com/twsl) |
| *Categories* | Core, Languages |
| *Definition type* | Dockerfile |
| *Published image* | mcr.microsoft.com/vscode/devcontainers/cuda |
| *Available image variants* | 3, 3.6, 3.7, 3.8, 3.9, 3.10 ([full list](https://mcr.microsoft.com/v2/vscode/devcontainers/cuda/tags/list)) |
| *Published image architecture(s)* | x86-64 |
| *Works in Codespaces* | No |
| *Container Host OS Support* | Linux, Windows |
| *Container OS* | Ubuntu |
| *Languages, platforms* | Python |

## Using this definition

### Configuration

While the definition itself works unmodified, you can select the version of Python the container uses by updating the `VARIANT` arg in the included `devcontainer.json` (and rebuilding if you've already created the container).

```json
"args": { "VARIANT": "3.9" }
```

You can also directly reference pre-built versions of `.devcontainer/base.Dockerfile` by using the `image` property in `.devcontainer/devcontainer.json` or updating the `FROM` statement in your own `Dockerfile` with one of the following:

- `mcr.microsoft.com/vscode/devcontainers/cuda:3` (latest)
- `mcr.microsoft.com/vscode/devcontainers/cuda:3.6`
- `mcr.microsoft.com/vscode/devcontainers/cuda:3.7`
- `mcr.microsoft.com/vscode/devcontainers/cuda:3.8`
- `mcr.microsoft.com/vscode/devcontainers/cuda:3.9`
- `mcr.microsoft.com/vscode/devcontainers/cuda:3.10`

You can decide how often you want updates by referencing a [semantic version](https://semver.org/) of each image. For example:

- `mcr.microsoft.com/vscode/devcontainers/python:0-3.9`
- `mcr.microsoft.com/vscode/devcontainers/python:0.1-3.9`
- `mcr.microsoft.com/vscode/devcontainers/python:0.1.0-3.9`

See [history](history) for information on the contents of each version and [here for a complete list of available tags](https://mcr.microsoft.com/v2/vscode/devcontainers/cuda/tags/list).

Alternatively, you can use the contents of `base.Dockerfile` to fully customize the your container's contents or build for a container architecture the image does not support.

Beyond Python and `git`, this image / `Dockerfile` includes a number of Python tools, `zsh`, [Oh My Zsh!](https://ohmyz.sh/), a non-root `vscode` user with `sudo` access, and a set of common dependencies for development.

### Installing Node.js

Given JavaScript front-end web client code written for use in conjunction with a Python back-end often requires the use of Node.js-based utilities to build, this container also includes `nvm` so that you can easily install Node.js. You can change the version of Node.js installed or disable its installation by updating the `args` property in `.devcontainer/devcontainer.json`.

```jsonc
"args": {
    "VARIANT": "3",
    "NODE_VERSION": "10" // Set to "none" to skip Node.js installation
}
```

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE)
