# GitHub Codespaces Support

[GitHub Codespaces](https://github.com/features/codespaces) is a service that enables you to work with development containers entirely in the cloud. While most of the definitions in this repository work with the service, there are a few that are not yet supported. The table below outlines what is expect to work.

## Expected to work (Alphabetical)

* azure-ansible
* azure-blockchain
* azure-cli
* azure-functions-dotnetcore-2.1
* azure-functions-dotnetcore-3.1
* azure-functions-java-8
* azure-functions-java-11
* azure-functions-node
* azure-functions-node
* azure-functions-pwsh
* azure-functions-python-3
* azure-machine-learning-python-3
* azure-terraform
* bash
* bazel
* codespaces-linux
* cpp
* dapr-dotnetcore-3.1
* dapr-typescript-node-12
* dart
* debian
* deno
* docker-from-docker
* docker-from-docker-compose
* dotnetcore
* dotnetcore-fsharp
* elm
* go
* java
* java-8
* javascript-node
* javascript-node-mongo
* javascript-node-postgres
* jekyll
* kubernetes-helm
* markdown
* perl
* php
* php-mariadb
* powershell
* puppet
* python-3
* python-3-anaconda
* python-3-miniconda
* python-3-postgres
* ruby
* ruby-rails
* ruby-sinatra
* rust
* sfdx-project
* swift-4
* typescript-node
* ubuntu
* vue

## Not currently working

* alpine - Due to [#458](https://github.com/MicrosoftDocs/vsonline/issues/458).
* bash - Due to [#458](https://github.com/MicrosoftDocs/vsonline/issues/458).
* reasonml - Build fails, but builds successfully locally. Something about the use of PPAs for fish
* r - Language server crash. More investigation needed.
