# [java](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/java)

**Image version:** dev

**Source release/branch:** [main](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/java)

**Definition variations:**
- [17-bullseye](#variant-17-bullseye)
- [17-buster](#variant-17-buster)
- [11-bullseye](#variant-11-bullseye)
- [11-buster](#variant-11-buster)

## Variant: 17-bullseye

**Digest:** sha256:466102a63b11891a99217f37df7bc966bfe561e4f8fc09f7af5729eb89ea58ca

**Tags:**
```
mcr.microsoft.com/vscode/devcontainers/java:dev-17-bullseye
mcr.microsoft.com/vscode/devcontainers/java:dev-17
mcr.microsoft.com/vscode/devcontainers/java:dev-17-jdk-bullseye
mcr.microsoft.com/vscode/devcontainers/java:dev-bullseye
```
> *To keep up to date, we recommend using partial version numbers. Use the major version number to get all non-breaking changes (e.g. `0-`) or major and minor to only get fixes (e.g. `0.200-`).*

**Linux distribution:** Debian GNU/Linux 11 (bullseye)

**Architectures:** linux/amd64, linux/arm64

**Available (non-root) user:** vscode

### Contents
**Languages and runtimes**

| Language / runtime | Version | Path |
|--------------------|---------|------|
| [Java](https://adoptopenjdk.net/) | 17.0.1 | /usr/local/ |

**Tools installed using git**

| Tool | Commit | Path |
|------|--------|------|
| [Oh My Zsh!](https://github.com/ohmyzsh/ohmyzsh) | 841f3cb0bb7663fa1062ffc59acb7b4581dc1d0f | /home/vscode/.oh-my-zsh |
| [nvm](https://github.com/nvm-sh/nvm.git) | 3fea5493a431ac64470d4230d4b51438cf213bd1 | /usr/local/share/nvm |

**Other tools and utilities**

| Tool | Version | Path |
|------|---------|------|
| [SDKMAN!](https://github.com/sdkman/sdkman-cli) | 5.13.1 | /usr/local/sdkman |

**Additional linux tools and packages**

| Tool / library | Version |
|----------------|---------|
| apt-transport-https | 2.2.4 |
| apt-utils | 2.2.4 |
| ca-certificates | 20210119 |
| curl | 7.74.0-1.3+b1 |
| dialog | 1.3-20201126-1 |
| git | 1:2.30.2-1 |
| gnupg2 | 2.2.27-2 |
| htop | 3.0.5-7 |
| iproute2 | 5.10.0-4 |
| jq | 1.6-2.1 |
| less | 551-2 |
| libc6 | 2.31-13+deb11u2 |
| libgssapi-krb5-2 | 1.18.3-6+deb11u1 |
| libicu67 | 67.1-7 |
| libkrb5-3 | 1.18.3-6+deb11u1 |
| liblttng-ust0 | 2.12.1-1 |
| libssl1.1 | 1.1.1k-1+deb11u1 |
| libstdc++6 | 10.2.1-6 |
| locales | 2.31-13+deb11u2 |
| lsb-release | 11.1.0 |
| lsof | 4.93.2+dfsg-1.1 |
| man-db | 2.9.4-2 |
| manpages | 5.10-1 |
| manpages-dev | 5.10-1 |
| manpages-posix | 2017a-2 |
| manpages-posix-dev | 2017a-2 |
| nano | 5.4-2 |
| ncdu | 1.15.1-1 |
| net-tools | 1.60+git20181103.0eebece-1 |
| openssh-client | 1:8.4p1-5 |
| procps | 2:3.3.17-5 |
| psmisc | 23.4-2 |
| rsync | 3.2.3-4+deb11u1 |
| strace | 5.10-1 |
| sudo | 1.9.5p2-3 |
| unzip | 6.0-26 |
| vim-tiny | 2:8.2.2434-3 |
| wget | 1.21-1+b1 |
| yarn | 1.22.15-1 |
| zip | 3.0-12 |
| zlib1g | 1:1.2.11.dfsg-2 |
| zsh | 5.8-6+b2 |

## Variant: 17-buster

**Digest:** sha256:276d983e130b82f226b0888d96351703d29353f278fd79259aa29e1acc0e2a4b

**Tags:**
```
mcr.microsoft.com/vscode/devcontainers/java:dev-17-buster
```
> *To keep up to date, we recommend using partial version numbers. Use the major version number to get all non-breaking changes (e.g. `0-`) or major and minor to only get fixes (e.g. `0.200-`).*

**Linux distribution:** Debian GNU/Linux 10 (buster)

**Architectures:** linux/amd64

**Available (non-root) user:** vscode

### Contents
**Languages and runtimes**

| Language / runtime | Version | Path |
|--------------------|---------|------|
| [Java](https://adoptopenjdk.net/) | 17.0.1 | /usr/local/ |

**Tools installed using git**

| Tool | Commit | Path |
|------|--------|------|
| [Oh My Zsh!](https://github.com/ohmyzsh/ohmyzsh) | 841f3cb0bb7663fa1062ffc59acb7b4581dc1d0f | /home/vscode/.oh-my-zsh |
| [nvm](https://github.com/nvm-sh/nvm.git) | 3fea5493a431ac64470d4230d4b51438cf213bd1 | /usr/local/share/nvm |

**Other tools and utilities**

| Tool | Version | Path |
|------|---------|------|
| [SDKMAN!](https://github.com/sdkman/sdkman-cli) | 5.13.1 | /usr/local/sdkman |

**Additional linux tools and packages**

| Tool / library | Version |
|----------------|---------|
| apt-transport-https | 1.8.2.3 |
| apt-utils | 1.8.2.3 |
| ca-certificates | 20200601~deb10u2 |
| curl | 7.64.0-4+deb10u2 |
| dialog | 1.3-20190211-1 |
| git | 1:2.20.1-2+deb10u3 |
| gnupg2 | 2.2.12-1+deb10u1 |
| htop | 2.2.0-1+b1 |
| iproute2 | 4.20.0-2+deb10u1 |
| jq | 1.5+dfsg-2+b1 |
| less | 487-0.1+b1 |
| libc6 | 2.28-10 |
| libgcc1 | 1:8.3.0-6 |
| libgssapi-krb5-2 | 1.17-3+deb10u3 |
| libicu63 | 63.1-6+deb10u2 |
| libkrb5-3 | 1.17-3+deb10u3 |
| liblttng-ust0 | 2.10.3-1 |
| libssl1.1 | 1.1.1d-0+deb10u7 |
| libstdc++6 | 8.3.0-6 |
| locales | 2.28-10 |
| lsb-release | 10.2019051400 |
| lsof | 4.91+dfsg-1 |
| man-db | 2.8.5-2 |
| manpages | 4.16-2 |
| manpages-dev | 4.16-2 |
| manpages-posix | 2013a-2 |
| manpages-posix-dev | 2013a-2 |
| nano | 3.2-3 |
| ncdu | 1.13-1+b1 |
| net-tools | 1.60+git20180626.aebd88e-1 |
| openssh-client | 1:7.9p1-10+deb10u2 |
| procps | 2:3.3.15-2 |
| psmisc | 23.2-1+deb10u1 |
| rsync | 3.1.3-6 |
| strace | 4.26-0.2 |
| sudo | 1.8.27-1+deb10u3 |
| unzip | 6.0-23+deb10u2 |
| vim-tiny | 2:8.1.0875-5 |
| wget | 1.20.1-1.1 |
| yarn | 1.22.15-1 |
| zip | 3.0-11+b1 |
| zlib1g | 1:1.2.11.dfsg-1 |
| zsh | 5.7.1-1 |

## Variant: 11-bullseye

**Digest:** sha256:5732506449476ecfd4e620e398aec093cc37c383c400e9fc9d96f890ad4149e4

**Tags:**
```
mcr.microsoft.com/vscode/devcontainers/java:dev-11-bullseye
mcr.microsoft.com/vscode/devcontainers/java:dev-11
mcr.microsoft.com/vscode/devcontainers/java:dev-11-jdk-bullseye
```
> *To keep up to date, we recommend using partial version numbers. Use the major version number to get all non-breaking changes (e.g. `0-`) or major and minor to only get fixes (e.g. `0.200-`).*

**Linux distribution:** Debian GNU/Linux 11 (bullseye)

**Architectures:** linux/amd64, linux/arm64

**Available (non-root) user:** vscode

### Contents
**Languages and runtimes**

| Language / runtime | Version | Path |
|--------------------|---------|------|
| [Java](https://adoptopenjdk.net/) | 11.0.13 | /usr/local/ |

**Tools installed using git**

| Tool | Commit | Path |
|------|--------|------|
| [Oh My Zsh!](https://github.com/ohmyzsh/ohmyzsh) | 841f3cb0bb7663fa1062ffc59acb7b4581dc1d0f | /home/vscode/.oh-my-zsh |
| [nvm](https://github.com/nvm-sh/nvm.git) | 3fea5493a431ac64470d4230d4b51438cf213bd1 | /usr/local/share/nvm |

**Other tools and utilities**

| Tool | Version | Path |
|------|---------|------|
| [SDKMAN!](https://github.com/sdkman/sdkman-cli) | 5.13.1 | /usr/local/sdkman |

**Additional linux tools and packages**

| Tool / library | Version |
|----------------|---------|
| apt-transport-https | 2.2.4 |
| apt-utils | 2.2.4 |
| ca-certificates | 20210119 |
| curl | 7.74.0-1.3+b1 |
| dialog | 1.3-20201126-1 |
| git | 1:2.30.2-1 |
| gnupg2 | 2.2.27-2 |
| htop | 3.0.5-7 |
| iproute2 | 5.10.0-4 |
| jq | 1.6-2.1 |
| less | 551-2 |
| libc6 | 2.31-13+deb11u2 |
| libgssapi-krb5-2 | 1.18.3-6+deb11u1 |
| libicu67 | 67.1-7 |
| libkrb5-3 | 1.18.3-6+deb11u1 |
| liblttng-ust0 | 2.12.1-1 |
| libssl1.1 | 1.1.1k-1+deb11u1 |
| libstdc++6 | 10.2.1-6 |
| locales | 2.31-13+deb11u2 |
| lsb-release | 11.1.0 |
| lsof | 4.93.2+dfsg-1.1 |
| man-db | 2.9.4-2 |
| manpages | 5.10-1 |
| manpages-dev | 5.10-1 |
| manpages-posix | 2017a-2 |
| manpages-posix-dev | 2017a-2 |
| nano | 5.4-2 |
| ncdu | 1.15.1-1 |
| net-tools | 1.60+git20181103.0eebece-1 |
| openssh-client | 1:8.4p1-5 |
| procps | 2:3.3.17-5 |
| psmisc | 23.4-2 |
| rsync | 3.2.3-4+deb11u1 |
| strace | 5.10-1 |
| sudo | 1.9.5p2-3 |
| unzip | 6.0-26 |
| vim-tiny | 2:8.2.2434-3 |
| wget | 1.21-1+b1 |
| yarn | 1.22.15-1 |
| zip | 3.0-12 |
| zlib1g | 1:1.2.11.dfsg-2 |
| zsh | 5.8-6+b2 |

## Variant: 11-buster

**Digest:** sha256:b74e6c151399cb94af5c612057188813e676fe0965110bc53ea4c85fb992b8a9

**Tags:**
```
mcr.microsoft.com/vscode/devcontainers/java:dev-11-buster
mcr.microsoft.com/vscode/devcontainers/java:dev-11-jdk-buster
```
> *To keep up to date, we recommend using partial version numbers. Use the major version number to get all non-breaking changes (e.g. `0-`) or major and minor to only get fixes (e.g. `0.200-`).*

**Linux distribution:** Debian GNU/Linux 10 (buster)

**Architectures:** linux/amd64

**Available (non-root) user:** vscode

### Contents
**Languages and runtimes**

| Language / runtime | Version | Path |
|--------------------|---------|------|
| [Java](https://adoptopenjdk.net/) | 11.0.13 | /usr/local/ |

**Tools installed using git**

| Tool | Commit | Path |
|------|--------|------|
| [Oh My Zsh!](https://github.com/ohmyzsh/ohmyzsh) | 841f3cb0bb7663fa1062ffc59acb7b4581dc1d0f | /home/vscode/.oh-my-zsh |
| [nvm](https://github.com/nvm-sh/nvm.git) | 3fea5493a431ac64470d4230d4b51438cf213bd1 | /usr/local/share/nvm |

**Other tools and utilities**

| Tool | Version | Path |
|------|---------|------|
| [SDKMAN!](https://github.com/sdkman/sdkman-cli) | 5.13.1 | /usr/local/sdkman |

**Additional linux tools and packages**

| Tool / library | Version |
|----------------|---------|
| apt-transport-https | 1.8.2.3 |
| apt-utils | 1.8.2.3 |
| ca-certificates | 20200601~deb10u2 |
| curl | 7.64.0-4+deb10u2 |
| dialog | 1.3-20190211-1 |
| git | 1:2.20.1-2+deb10u3 |
| gnupg2 | 2.2.12-1+deb10u1 |
| htop | 2.2.0-1+b1 |
| iproute2 | 4.20.0-2+deb10u1 |
| jq | 1.5+dfsg-2+b1 |
| less | 487-0.1+b1 |
| libc6 | 2.28-10 |
| libgcc1 | 1:8.3.0-6 |
| libgssapi-krb5-2 | 1.17-3+deb10u3 |
| libicu63 | 63.1-6+deb10u2 |
| libkrb5-3 | 1.17-3+deb10u3 |
| liblttng-ust0 | 2.10.3-1 |
| libssl1.1 | 1.1.1d-0+deb10u7 |
| libstdc++6 | 8.3.0-6 |
| locales | 2.28-10 |
| lsb-release | 10.2019051400 |
| lsof | 4.91+dfsg-1 |
| man-db | 2.8.5-2 |
| manpages | 4.16-2 |
| manpages-dev | 4.16-2 |
| manpages-posix | 2013a-2 |
| manpages-posix-dev | 2013a-2 |
| nano | 3.2-3 |
| ncdu | 1.13-1+b1 |
| net-tools | 1.60+git20180626.aebd88e-1 |
| openssh-client | 1:7.9p1-10+deb10u2 |
| procps | 2:3.3.15-2 |
| psmisc | 23.2-1+deb10u1 |
| rsync | 3.1.3-6 |
| strace | 4.26-0.2 |
| sudo | 1.8.27-1+deb10u3 |
| unzip | 6.0-23+deb10u2 |
| vim-tiny | 2:8.1.0875-5 |
| wget | 1.20.1-1.1 |
| yarn | 1.22.15-1 |
| zip | 3.0-11+b1 |
| zlib1g | 1:1.2.11.dfsg-1 |
| zsh | 5.7.1-1 |

