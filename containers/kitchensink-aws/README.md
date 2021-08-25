# Kitchen Sink - AWS

## Summary

Used to manage a cloud stack and applications.  Includes support for various languages alongside Terraform and AWS CLI tools.  It optionally (remove commented services in [docker-compose.yml](.devcontainer/docker-compose.yml) includes a Postgres DB container and a pgAdmin4 container which again mounts a Windows folder.

| Metadata | Value |
|----------|-------|
| *Contributors* | [Jon Benson](https://github.com/hastarin) |
| *Definition type* | Docker Compose |
| *Languages, platforms* | AWS, Multiple Languages |

## Description

This is a template for a multilanguage development environment for working with Terraform and AWS.

At a minimum you should edit the various environment variables in the [docker-compose.yml](.devcontainer/docker-compose.yml) and uncomment the relevant line for your OS if you want to mount your terraform.rc file for use with [Terraform Cloud](https://learn.hashicorp.com/terraform/cloud/tf_cloud_gettingstarted).

A variation of this has been used for limited development on Windows.  It has not been tested on Mac/Linux.

It is suggested you comment out things you don't need from the [Dockerfile](.devcontainer/Dockerfile) and [devcontainer.json](.devcontainer/devcontainer.json).

The Dockerfile has been built in layers and each is commented so you can comment out any you don't need/want.

If you don't need/want dotnet core SDK then change the base image to buildpack-deps:bionic-scm.

This is based on the dotnet core SDK 2.2 bionic container and includes the following:
* dotnet SDK 2.2 and AWS Lambda Templates/Tools
* git, wget, curl, unzip
* Terraform, tflint, and graphviz
* AWS CLI and AWS IAM Authenticator
* NodeJS 10.x and Yarn
* Serverless Framework
* Python 3.6.x
* Brew
* AWS SAM CLI
* Postgresql 11 cient
* kubectl
* docker-in-docker support
* Postgres 11 server (remove commented services in [docker-compose.yml](.devcontainer/docker-compose.yml) 
* pgAdmin4 server (remove commented services in [docker-compose.yml](.devcontainer/docker-compose.yml) 
* awsenv

The following Visual Studio Code Extensions are also included:
* [Terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)
* [Trailing Spaces](https://marketplace.visualstudio.com/items?itemName=shardulm94.trailing-spaces)
* [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
* [AWS Toolkit for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=amazonwebservices.aws-toolkit-vscode)
* [AWS CLI Configure](https://marketplace.visualstudio.com/items?itemName=mark-tucker.aws-cli-configure)
* [Resource Monitor](https://marketplace.visualstudio.com/items?itemName=mutantdino.resourcemonitor)
* [C#](https://marketplace.visualstudio.com/items?itemName=ms-vscode.csharp)
* [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
* [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)

## Using this definition with an existing folder

This presumes the following Windows folders/files exist:
* %USERPROFILE%\\.aws - Gets mounted as ~/.aws
* %APPDATA%\\terraform.rc - Gets copied to ~/.terraform.rc
* %APPDATA%\\pgAdminServer - If available is mounted in pgAdmin4 container

This has not been tested on Mac/Linux.  You will need to change mount points in the [docker-compose.yml](.devcontainer/docker-compose.yml).

Just follow these steps:

1. If this is your first time using a development container, please follow the [getting started steps](https://aka.ms/vscode-remote/containers/getting-started) to set up your machine.

2. To use VS Code's copy of this definition:
   1. Start VS Code and open your project folder.
   2. Press <kbd>F1</kbd> select and **Remote-Containers: Add Development Container Configuration Files...** from the command palette.
   3. Select the Kitchen Sink - AWS definition.

3. To use latest-and-greatest copy of this definition from the repository:
   1. Clone this repository.
   2. Copy the contents of this folder in the cloned repository to the root of your project folder.
   3. Start VS Code and open your project folder.

4. After following step 2 or 3, the contents of the `.devcontainer` folder in your project can be adapted to meet your needs.

5. Finally, press <kbd>F1</kbd> and run **Remote-Containers: Reopen Folder in Container** to start using the definition.

## How it works

Setup to use a vscode non root user.  Beware of [quirks](https://code.visualstudio.com/docs/remote/containers-advanced#_adding-a-nonroot-user-to-your-dev-container).

It (optionally) provides a local Postgres database on port 5433.

It also (optionally) provides a local [pgAdmin4 Server](http://localhost:5050/).

You can set the default credentials for both in the [docker-compose.yml](.devcontainer/docker-compose.yml).

## License

Copyright (c) Microsoft Corporation. All rights reserved.

Licensed under the MIT License. See [LICENSE](https://github.com/Microsoft/vscode-dev-containers/blob/master/LICENSE).