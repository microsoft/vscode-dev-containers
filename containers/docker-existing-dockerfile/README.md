# Existing Dockerfile Sample

## Summary

*Illustrates you can reuse an existing Dockerfile for your dev container.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code team |
| *Definition type* | Dockerfile |
| *Languages, platforms* | Any |

> **Note:** There is also a [Docker Compose](../docker-existing-docker-compose) variation of this same definition.

## Usage

To use the definition with your own project that contains a `Dockerfile`:

1. Copy the `.devcontainer` folder into your project root.
2. Modify the `.devcontainer/devcontainer.json` as needed (see comments)
3. Reopen the folder in the container (e.g. using the **Remote-Container: Reopen Folder in Container** command in VS Code) to use it unmodified.

[See here for more information on using this definition with an existing project](../../README.md#using-a-definition).

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](../../LICENSE). 
