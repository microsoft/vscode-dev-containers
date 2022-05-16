# PHP & Azure SQL/SQL Server (Community)

## Summary

*Develop PHP based applications using Azure SQL DB, Azure SQL MI or SQL Server. Includes needed tools, extensions, dependencies and samples*

| Metadata | Value |  
|----------|-------|
| *Contributors* | [Davide Mauri]() |
| *Categories* | Community, Languages |
| *Definition type* | Docker Compose |
| *Published images* | mcr.microsoft.com/vscode/devcontainers/php |
| *Container host OS support* | Linux, macOS, Windows |
| *Container OS* | Debian |
| *Languages, platforms* | PHP, MS SQL Server |

## Description

This definition creates two containers, one for PHP and one for Microsoft SQL Server (MSSQL). Code will attach to the PHP container, and from within that container the MSSQL container will be available on localhost port 1433. The MSSQL instance can be managed from the container's command line with:

```
sqlcmd -S localhost -U sa -P A_STR0NG_Passw0rd! -C
```

Or connecting with [Microsoft SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms) or [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio) or the [MSSQL Server VS Code Extension](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql). The VS Code Extension is automatically installed and configured for accessing the Microsoft SQL Server instance running in the dedicated container. Look for the profile `php-mssql-container` in the SQL Server tab.

## Using this definition

This definition has been created using the PHP defintion as starting point. It has been tested using the `8.1-bullseye` variant (Debian Buster and PHP 8.1.). Please refer to the PHP devcontainer repository for any additional information on how to customize the image:

https://github.com/microsoft/vscode-dev-containers/tree/main/containers/php


## Testing the definition

This definition includes some test code that will help you verify it is working as expected on your system. Follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.
2. Clone this repository.
3. Start VS Code, press <kbd>F1</kbd>, and select **Remote-Containers: Open Folder in Container...**
4. Select the `containers/php` folder.
5. After the folder has opened in the container, press <kbd>F5</kbd> to start the project.
6. You should see "Hello remote world!" in the Debug Console after the program executes.
7. From here, you can add breakpoints or edit the contents of the `test-project` folder to do further testing.

## Testing PHP and SQL Server

The defintion include couple of files to test that PHP can successfuly connect and query SQL Server or Azure SQL. The files are in the `test-project` folder: `sqlsrv.php` and `sqlsrvdpo.php`.

They will both try to connect to the MS SQL Server running in the container and will query the server version. To test if everything works you can press F5 so that the debug configuration `Launch Built-in web server` will be launched. It will open a browser and automatically  navigate to:

http://localhost:37135/test-project/sqlsrv.php

to check the everything working. If it does you'll see something like:

```
Microsoft SQL Server 2019 (RTM-CU15) (KB5008996) - 15.0.4198.2 (X64) Jan 12 2022 22:30:08 Copyright (C) 2019 Microsoft Corporation Developer Edition (64-bit) on Linux (Ubuntu 20.04.3 LTS)
```

You can also set breakpoints, as dubugging is supported via XDebug.

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/microsoft/vscode-dev-containers/blob/main/LICENSE).