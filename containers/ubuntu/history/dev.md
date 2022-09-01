# [ubuntu](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/ubuntu)

**Image version:** dev

**Source release/branch:** [main](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/ubuntu)

**Definition variations:**
- [jammy](#variant-jammy)
- [focal](#variant-focal)
- [bionic](#variant-bionic)

## Variant: jammy

**Digest:** sha256:c17bebbf7c6a30504db0da3285e6ffc7f80fdf4196de164e02d8a9cf2f46cd6e

**Tags:**
```
mcr.microsoft.com/vscode/devcontainers/base:dev-jammy
mcr.microsoft.com/vscode/devcontainers/base:dev-ubuntu-22.04
mcr.microsoft.com/vscode/devcontainers/base:dev-ubuntu22.04
```
> *To keep up to date, we recommend using partial version numbers. Use the major version number to get all non-breaking changes (e.g. `0-`) or major and minor to only get fixes (e.g. `0.200-`).*

**Linux distribution:** Ubuntu 22.04.1 LTS (debian-like distro)

**Architectures:** linux/amd64, linux/arm64

**Available (non-root) user:** vscode

### Contents
**Tools installed using git**

| Tool | Commit | Path |
|------|--------|------|
| [Oh My Zsh!](https://github.com/ohmyzsh/ohmyzsh) | 3668ec2a82250020ca0c285ef8b277f1385a8085 | /home/vscode/.oh-my-zsh |

**Additional linux tools and packages**

| Tool / library | Version |
|----------------|---------|
| apt-transport-https | 2.4.7 |
| apt-utils | 2.4.7 |
| ca-certificates | 20211016 |
| curl | 7.81.0-1ubuntu1.3 |
| dialog | 1.3-20211214-1 |
| git | 1:2.34.1-1ubuntu1.4 |
| gnupg2 | 2.2.27-3ubuntu2.1 |
| htop | 3.0.5-7build2 |
| iproute2 | 5.15.0-1ubuntu2 |
| jq | 1.6-2.1ubuntu3 |
| less | 590-1build1 |
| libc6 | 2.35-0ubuntu3.1 |
| libgssapi-krb5-2 | 1.19.2-2 |
| libicu70 | 70.1-2 |
| libkrb5-3 | 1.19.2-2 |
| libstdc++6 | 12-20220319-1ubuntu1 |
| locales | 2.35-0ubuntu3.1 |
| lsb-release | 11.1.0ubuntu4 |
| lsof | 4.93.2+dfsg-1.1build2 |
| man-db | 2.10.2-1 |
| manpages | 5.10-1ubuntu1 |
| manpages-dev | 5.10-1ubuntu1 |
| manpages-posix | 2017a-2 |
| manpages-posix-dev | 2017a-2 |
| nano | 6.2-1 |
| ncdu | 1.15.1-1 |
| net-tools | 1.60+git20181103.0eebece-1ubuntu5 |
| openssh-client | 1:8.9p1-3 |
| procps | 2:3.3.17-6ubuntu2 |
| psmisc | 23.4-2build3 |
| rsync | 3.2.3-8ubuntu3 |
| strace | 5.16-0ubuntu3 |
| sudo | 1.9.9-1ubuntu2 |
| unzip | 6.0-26ubuntu3 |
| vim-tiny | 2:8.2.3995-1ubuntu2 |
| wget | 1.21.2-2ubuntu1 |
| zip | 3.0-12build2 |
| zlib1g | 1:1.2.11.dfsg-2ubuntu9 |
| zsh | 5.8.1-1 |

## Variant: focal

**Digest:** sha256:0d5bb6d223466163e313a787c9338473844162f366dda6b8553a0d747c520d53

**Tags:**
```
mcr.microsoft.com/vscode/devcontainers/base:dev-focal
mcr.microsoft.com/vscode/devcontainers/base:dev-ubuntu-20.04
mcr.microsoft.com/vscode/devcontainers/base:dev-ubuntu20.04
mcr.microsoft.com/vscode/devcontainers/base:dev-ubuntu
```
> *To keep up to date, we recommend using partial version numbers. Use the major version number to get all non-breaking changes (e.g. `0-`) or major and minor to only get fixes (e.g. `0.200-`).*

**Linux distribution:** Ubuntu 20.04.4 LTS (debian-like distro)

**Architectures:** linux/amd64

**Available (non-root) user:** vscode

### Contents
**Tools installed using git**

| Tool | Commit | Path |
|------|--------|------|
| [Oh My Zsh!](https://github.com/ohmyzsh/ohmyzsh) | 3668ec2a82250020ca0c285ef8b277f1385a8085 | /home/vscode/.oh-my-zsh |

**Additional linux tools and packages**

| Tool / library | Version |
|----------------|---------|
| apt-transport-https | 2.0.9 |
| apt-utils | 2.0.9 |
| ca-certificates | 20211016~20.04.1 |
| curl | 7.68.0-1ubuntu2.12 |
| dialog | 1.3-20190808-1 |
| git | 1:2.25.1-1ubuntu3.5 |
| gnupg2 | 2.2.19-3ubuntu2.2 |
| htop | 2.2.0-2build1 |
| iproute2 | 5.5.0-1ubuntu1 |
| jq | 1.6-1ubuntu0.20.04.1 |
| less | 551-1ubuntu0.1 |
| libc6 | 2.31-0ubuntu9.9 |
| libgcc1 | 1:10.3.0-1ubuntu1~20.04 |
| libgssapi-krb5-2 | 1.17-6ubuntu4.1 |
| libicu66 | 66.1-2ubuntu2.1 |
| libkrb5-3 | 1.17-6ubuntu4.1 |
| liblttng-ust0 | 2.11.0-1 |
| libssl1.1 | 1.1.1f-1ubuntu2.16 |
| libstdc++6 | 10.3.0-1ubuntu1~20.04 |
| locales | 2.31-0ubuntu9.9 |
| lsb-release | 11.1.0ubuntu2 |
| lsof | 4.93.2+dfsg-1ubuntu0.20.04.1 |
| man-db | 2.9.1-1 |
| manpages | 5.05-1 |
| manpages-dev | 5.05-1 |
| manpages-posix | 2013a-2 |
| manpages-posix-dev | 2013a-2 |
| nano | 4.8-1ubuntu1 |
| ncdu | 1.14.1-1 |
| net-tools | 1.60+git20180626.aebd88e-1ubuntu1 |
| openssh-client | 1:8.2p1-4ubuntu0.5 |
| procps | 2:3.3.16-1ubuntu2.3 |
| psmisc | 23.3-1 |
| rsync | 3.1.3-8ubuntu0.4 |
| strace | 5.5-3ubuntu1 |
| sudo | 1.8.31-1ubuntu1.2 |
| unzip | 6.0-25ubuntu1 |
| vim-tiny | 2:8.1.2269-1ubuntu5.7 |
| wget | 1.20.3-1ubuntu2 |
| zip | 3.0-11build1 |
| zlib1g | 1:1.2.11.dfsg-2ubuntu1.3 |
| zsh | 5.8-3ubuntu1.1 |

## Variant: bionic

**Digest:** sha256:ed5996d06d022497fd13669746daebec0bccbf2dd44c1606af1d87f9830aa00e

**Tags:**
```
mcr.microsoft.com/vscode/devcontainers/base:dev-bionic
mcr.microsoft.com/vscode/devcontainers/base:dev-ubuntu-18.04
mcr.microsoft.com/vscode/devcontainers/base:dev-ubuntu18.04
```
> *To keep up to date, we recommend using partial version numbers. Use the major version number to get all non-breaking changes (e.g. `0-`) or major and minor to only get fixes (e.g. `0.200-`).*

**Linux distribution:** Ubuntu 18.04.6 LTS (debian-like distro)

**Architectures:** linux/amd64, linux/arm64

**Available (non-root) user:** vscode

### Contents
**Tools installed using git**

| Tool | Commit | Path |
|------|--------|------|
| [Oh My Zsh!](https://github.com/ohmyzsh/ohmyzsh) | 3668ec2a82250020ca0c285ef8b277f1385a8085 | /home/vscode/.oh-my-zsh |

**Additional linux tools and packages**

| Tool / library | Version |
|----------------|---------|
| apt-transport-https | 1.6.14 |
| apt-utils | 1.6.14 |
| ca-certificates | 20211016~18.04.1 |
| curl | 7.58.0-2ubuntu3.19 |
| dialog | 1.3-20171209-1 |
| git | 1:2.17.1-1ubuntu0.12 |
| gnupg2 | 2.2.4-1ubuntu1.6 |
| htop | 2.1.0-3 |
| iproute2 | 4.15.0-2ubuntu1.3 |
| jq | 1.5+dfsg-2 |
| less | 487-0.1 |
| libc6 | 2.27-3ubuntu1.6 |
| libgcc1 | 1:8.4.0-1ubuntu1~18.04 |
| libgssapi-krb5-2 | 1.16-2ubuntu0.2 |
| libicu60 | 60.2-3ubuntu3.2 |
| libkrb5-3 | 1.16-2ubuntu0.2 |
| liblttng-ust0 | 2.10.1-1 |
| libssl1.0.0 | 1.0.2n-1ubuntu5.10 |
| libssl1.1 | 1.1.1-1ubuntu2.1~18.04.20 |
| libstdc++6 | 8.4.0-1ubuntu1~18.04 |
| locales | 2.27-3ubuntu1.6 |
| lsb-release | 9.20170808ubuntu1 |
| lsof | 4.89+dfsg-0.1 |
| man-db | 2.8.3-2ubuntu0.1 |
| manpages | 4.15-1 |
| manpages-dev | 4.15-1 |
| manpages-posix | 2013a-2 |
| manpages-posix-dev | 2013a-2 |
| nano | 2.9.3-2 |
| ncdu | 1.12-1 |
| net-tools | 1.60+git20161116.90da8a0-1ubuntu1 |
| openssh-client | 1:7.6p1-4ubuntu0.7 |
| procps | 2:3.3.12-3ubuntu1.2 |
| psmisc | 23.1-1ubuntu0.1 |
| rsync | 3.1.2-2.1ubuntu1.5 |
| strace | 4.21-1ubuntu1 |
| sudo | 1.8.21p2-3ubuntu1.4 |
| unzip | 6.0-21ubuntu1.1 |
| vim-tiny | 2:8.0.1453-1ubuntu1.8 |
| wget | 1.19.4-1ubuntu2.2 |
| zip | 3.0-11build1 |
| zlib1g | 1:1.2.11.dfsg-0ubuntu2.2 |
| zsh | 5.4.2-3ubuntu3.2 |

