# Python 3, Jupyter, & PySpark

## Summary

*A basic dev container definition that sets up Jupyter Notebooks in a container for use with the VS Code Python Extension. Includes everything you need to get up and running.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Definition type* | Docker Compose |
| *Languages, platforms* | Python, Jupyter, PySpark|

## Usage

[See here for information on using this definition with an existing project](../../README.md#using-a-definition).

The definition connects the Python Extension to Jupyter using a token. You can change this token by editing:

- The token portion of `python.dataScience.jupyterServerURI` in `.devcontainer/settings.vscode.json`
- The the value of `c.NotebookApp.token` in `jupyter_notebook_config.py`

...and then running **Remote-Containers: Rebuild Container**.

If you prefer, you can also just look through the contents of the `.devcontainer` folder to understand how to make changes to your own project.

If you want to try out the test project instead, run **Remote-Container: Open Folder in Container...** in VS Code and select a cloned copy of the entire folder and using the Notebook in the `test-project` folder.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](../../LICENSE).
