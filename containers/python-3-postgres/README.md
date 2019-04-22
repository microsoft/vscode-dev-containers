# Python 3 & PostgreSQL

## Summary

*Develop applications with Python 3 and PostgreSQL. Includes a Python application container and PostgreSQL server, and a Django test project.*

| Metadata | Value |  
|----------|-------|
| *Contributors* | The VS Code Team |
| *Definition type* | Dockerfile |
| *Languages, platforms* | Python |

## Usage

[See here for information on using this definition with an existing project](https://aka.ms/vscode-remote/containers/getting-started/open).

If you prefer, you can also just look through the contents of the `.devcontainer` folder to understand how to make changes to your own project.

If you want to try out the test project instead, run **Remote-Container: Open Folder in Container...** in VS Code and select a cloned copy of the entire folder. 

Initialize the database and super user by opening the terminal and running:
```
cd test-project
python manage.py migrate
python manage.py createsuperuser
```

You can then start the test program from Debug panel in VS Code, or by running:
```
python manage.py runserver 0.0.0.0:5000
```

Then browse to [http://localhost:5000/admin](http://localhost:5000/admin) and login!

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).
