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
* dapr-dotnetcore-3.1
* dapr-typescript-node-12
* dart
* debian
* docker-from-docker
* docker-from-docker-compose
* dotnetcore
* dotnetcore-fsharp
* elm
* go
* java-8
* java-8-tomcat-8.5
* java-11
* java-12
* javascript-node
* javascript-node-mongo
* javascript-node-postgres
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
* typescript-node
* ubuntu

## Not currently working

* alpine-3.10-git - Due to [#458](https://github.com/MicrosoftDocs/vsonline/issues/458).
* bash - Due to [#458](https://github.com/MicrosoftDocs/vsonline/issues/458).
* hugo - Due to [#458](https://github.com/MicrosoftDocs/vsonline/issues/458).
* reasonml - Build fails, but builds successfully locally. Something about the use of PPAs for fish
* r - Language server crash. More investigation needed.
