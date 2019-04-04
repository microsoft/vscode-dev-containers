# PlantUML

## Summary

*A basic dev container definition for editing PlantUML in a container that includes Java and GraphViz and the PlantUML extension.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Definition type* | Dockerfile |
| *Languages, platforms* | PlantUML |

## Usage

First, install the **[Visual Studio Code Remote Development](https://aka.ms/vscode-remote/download/extension)** extension pack if you have not already.

To use the definition with your own project:

1. Copy the `.devcontainer` folder into your project root.
2. Reopen the folder in the container (e.g. using the **Remote-Container: Reopen Folder in Container** command in VS Code) to use it unmodified.

If you prefer, you can look through the contents of the `.devcontainer` folder to understand how to make changes to your own project.

If you want to try out the test project instead, run **Remote-Container: Open Folder in Container...** in VS Code and select a cloned copy of the entire folder. 

Check out the samples folder or just do a markdown preview on this file once you've opened this folder in the container!

```plantuml
@startuml
Brain -> Brain: Wait, VS Code can do that?
Brain -> Mouth: Say "Cool!"
Mouth -> Ear: Cool!
Ear -> Brain: Heard myself say Cool!
@enduml
````

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](../../LICENSE).
