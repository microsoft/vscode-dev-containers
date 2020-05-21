# Visual Studio Codespaces Support

[Visual Studio Codespaces](http://aka.ms/vso) is a service that enables you to work with development containers entirely in the cloud. While most of the definitions in this repository work with the service, there are a few that are not yet supported. The table below outlines what is expect to work.

## Expected to work (Alphabetical)

* azure-ansible
* azure-blockchain
* azure-cli
* azure-functions-dotnetcore-2.1
* azure-functions-dotnetcore-3.1
* azure-functions-java-8
* azure-functions-node-10
* azure-functions-node-12
* azure-functions-python-3
* azure-functions-pwsh-6
* azure-terraform-0.11
* azure-terraform-0.12
* azure-machine-learning-python-3
* bazel
* codespaces-linux
* cpp
* dart
* debian-9-git
* debian-10-git
* docker-in-docker
* docker-in-docker-compose
* dotnetcore-2.1
* dotnetcore-2.1-fsharp
* dotnetcore-3.0
* dotnetcore-3.0-fsharp
* dotnetcore-3.1
* dotnetcore-3.1-fsharp
* elm
* go
* java-8
* java-8-tomcat-8.5
* java-11
* java-12
* javascript-node-10
* javascript-node-12
* javascript-node-12-mongo
* javascript-node-12-postgres
* javascript-node-14
* jekyll
* kubernetes-helm
* markdown
* perl
* php-7
* php-7-mariadb
* plantuml
* powershell
* puppet
* python-3
* python-3-anaconda
* python-3-miniconda
* python-3-postgres
* ruby-2
* ruby-2-rails-5
* ruby-2-sinatra
* rust
* sfdx-project
* swift-4
* typescript-node-10
* typescript-node-12
* ubuntu-18.04-git

## Not currently working

* alpine-3.10-git - Due to [#458](https://github.com/MicrosoftDocs/vsonline/issues/458).
* dapr-dotnetcore-3.1 - Due to [#457](https://github.com/MicrosoftDocs/vsonline/issues/457).
* dapr-typescript-node-12 - Due to [#457](https://github.com/MicrosoftDocs/vsonline/issues/457).
* reasonml - Build fails, but builds successfully locally. Something about the use of PPAs for fish
* r - Language server crash. More investigation needed.

