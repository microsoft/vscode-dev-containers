# [codespaces-linux-stretch](https://github.com/microsoft/vscode-dev-containers/tree/master/containers/codespaces-linux-stretch)

**Image version:** dev

**Source release/branch:** [master](https://github.com/microsoft/vscode-dev-containers/tree/master/containers/codespaces-linux-stretch)

**Digest:** sha256:bc3fda468f8be500eff10c51c976bc6806c0228a4c59e3aec1a54d94f55e88a1

**Tags:**
```
mcr.microsoft.com/vscode/devcontainers/universal:dev-codespaceslinuxstretch-stretch
mcr.microsoft.com/vscode/devcontainers/universal:dev-codespaceslinuxstretch-linux
mcr.microsoft.com/vscode/devcontainers/universal:dev-codespaceslinuxstretch
```
> *To keep up to date, we recommend using partial version numbers. Use the major version number to get all non-breaking changes (e.g. `0-`) or major and minor to only get fixes (e.g. `0.200-`).*

**Linux distribution:** Debian GNU/Linux 9 (stretch)

**Available (non-root) user:** codespace

### Contents
**Languages and runtimes**

| Language / runtime | Version | Path |
|--------------------|---------|------|
| [Node.js](https://nodejs.org/en/) | 10.1.0<br />10.10.0<br />10.14.2<br />10.16.3<br />10.19.0<br />12.16.3<br />4.4.7<br />4.5.0<br />4.8.0<br />6.10.3<br />6.11.0<br />6.17.1<br />6.2.2<br />6.6.0<br />6.9.3<br />8.0.0<br />8.1.4<br />8.11.2<br />8.12.0<br />8.15.1<br />8.17.0<br />8.2.1<br />8.8.1<br />8.9.4<br />9.4.0 | /opt/nodejs/&lt;version&gt; |
| [Python](https://www.python.org/) | 2.7.17<br />3.6.10<br />3.7.7<br />3.8.3 | /opt/python/&lt;version&gt; |
| [Java](https://adoptopenjdk.net/) | 11.0.10 | /usr/local/sdkman/candidates/java/current |
| [.NET](https://dotnet.microsoft.com/) | 1.0.16<br />1.1.13<br />2.0.9<br />2.1.19<br />2.2.7<br />3.0.3<br />3.1.5 | /home/codespaces/.dotnet<br />/opt/dotnet |
| [Ruby](https://www.ruby-lang.org/en/) | 2.7.2p137 | /usr/local/rvm/rubies/ruby-&lt;version&gt; |
| [PHP](https://www.php.net/) | 5.6.40<br />7.0.33<br />7.2.28<br />7.3.15<br />7.4.3 | /opt/php/&lt;version&gt; |
| [PowerShell](https://docs.microsoft.com/en-us/powershell/) | 7.1.3 | /opt/microsoft/powershell |
| GCC | 6.3.0-18+deb9u1 | 
| Clang | 3.8.1-24 (tags/RELEASE_381/final) | 
| [Go](https://golang.org/dl) | 1.16.3 | /usr/local/go |
| [Rust](https://github.com/rust-lang/rust) | 1.51.0 | /usr/local/cargo |

**Tools installed using git**

| Tool | Commit | Path |
|------|--------|------|
| [Oh My Zsh!](https://github.com/ohmyzsh/ohmyzsh) | 63a7422d8dd5eb93c849df0ab9e679e6f333818a | /home/codespace/.oh-my-zsh |
| [nvm](https://github.com/nvm-sh/nvm.git) | 258938ef66a2a49a4a400554a6dce890226ae34c | /home/codespace/.nvm |
| [nvs](https://github.com/jasongin/nvs) | 9f7d7b7f3e9b78e9ac4228b97dc04878f9f831a2 | /home/codespace/.nvs |
| [rbenv](https://github.com/rbenv/rbenv.git) | 80af3592322a193b047c21d6a2c488b1cb5baa30 | /usr/local/share/rbenv |
| [ruby-build](https://github.com/rbenv/ruby-build.git) | 0bd64d37990908876e895aa471685d937f01a034 | /usr/local/share/ruby-build |

**Pip / pipx installed tools and packages**

| Tool / package | Version |
|----------------|---------|
| pylint | 2.8.2 |
| flake8 | 3.9.1 |
| autopep8 | 1.5.6 |
| black | 21.4b2 |
| yapf | 0.31.0 |
| mypy | 0.812 |
| pydocstyle | 6.0.0 |
| pycodestyle | 2.7.0 |
| bandit | 1.7.0 |
| virtualenv | 20.4.4 |
| pipx | 0.16.2.1 |

**Go tools and modules**

| Tool / module | Version |
|---------------|---------|
| golang.org/x/tools/gopls | 0.6.10 |
| honnef.co/go/tools | 0.1.3 |
| golang.org/x/lint | 0.0.0-20201208152925-83fdc39ff7b5 |
| github.com/mgechev/revive | 1.0.6 |
| github.com/uudashr/gopkgs | 1.3.2 |
| github.com/ramya-rao-a/go-outline | 0.0.0-20200117021646-2a048b4510eb |
| github.com/go-delve/delve | 1.6.0 |
| github.com/golangci/golangci-lint | 1.39.0 |

**Ruby gems and tools**

| Tool / gem | Version |
|------------|---------|
| rake | 13.0.1 |
| ruby-debug-ide | 0.7.2 |
| debase | 0.2.4.1 |

**Cargo / rustup (Rust) crates and tools**

| Tool / crate | Version |
|--------------|---------|
| rls | 1.41.0 |
| rustfmt | 1.4.36 |
| rust-analysis | 1.51.0 |
| rust-src | 1.51.0 |
| clippy | 1.51.0 |

**Other tools and utilities**

| Tool | Version | Path |
|------|---------|------|
| [git](https://github.com/git/git) | 2.31.1 | 
| [Xdebug](https://xdebug.org/) | 3.0.4 | 
| [Composer](https://getcomposer.org/) | 1.9.3 | 
| [kubectl](https://github.com/kubernetes/kubectl) | 1.21.0 | /usr/local/bin |
| [Helm](https://github.com/helm/helm) | 3.5.4 | /usr/local/bin |
| [Docker Compose](https://github.com/docker/compose) | 1.29.1 | /usr/local/bin |
| [SDKMAN!](https://github.com/sdkman/sdkman-cli) | 5.11.2+698 | /usr/local/sdkman |
| [rvm](https://github.com/rvm/rvm) | 1.29.12 | /usr/local/rvm |
| [GitHub CLI](https://github.com/cli/cli) | 1.9.2 | 
| [yarn](https://yarnpkg.com/) | 1.17.3 | /opt/yarn |
| [Maven](https://maven.apache.org/) | 3.8.1 | /opt/maven |
| [Gradle](https://gradle.org/) | 7.0 | 
| Docker (Moby) CLI | 20.10.6+azure | 

**Additional linux tools and packages**

| Tool / library | Version |
|----------------|---------|
| apt-transport-https | 1.4.11 |
| apt-utils | 1.4.11 |
| azure-cli (Azure CLI) | 2.22.1-1~stretch |
| build-essential | 12.3 |
| ca-certificates | 20200601~deb9u2 |
| clang | 1:3.8-36 |
| cmake | 3.7.2-1 |
| cppcheck | 1.76.1-1 |
| curl | 7.52.1-5+deb9u13 |
| dialog | 1.3-20160828-2 |
| g++ | 4:6.3.0-4 |
| gcc | 4:6.3.0-4 |
| gdb | 7.12-6 |
| git | 1:2.11.0-3+deb9u7 |
| git-lfs (Git Large File Support) | 2.13.3 |
| gnupg2 | 2.1.18-8~deb9u4 |
| htop | 2.0.2-1 |
| iproute2 | 4.9.0-1+deb9u1 |
| jq | 1.5+dfsg-1.3 |
| less | 481-2.1 |
| libc6 | 2.24-11+deb9u4 |
| libc6-dev | 2.24-11+deb9u4 |
| libgcc1 | 1:6.3.0-18+deb9u1 |
| libgssapi-krb5-2 | 1.15-1+deb9u2 |
| libicu57 | 57.1-6+deb9u4 |
| libkrb5-3 | 1.15-1+deb9u2 |
| liblttng-ust0 | 2.9.0-2+deb9u1 |
| libsecret-1-dev | 0.18.5-3.1 |
| libssl1.0.2 | 1.0.2u-1~deb9u4 |
| libssl1.1 | 1.1.0l-1~deb9u3 |
| libstdc++6 | 6.3.0-18+deb9u1 |
| lldb | 1:3.8-36 |
| llvm | 1:3.8-36 |
| locales | 2.24-11+deb9u4 |
| lsb-release | 9.20161125 |
| lsof | 4.89+dfsg-0.1 |
| make | 4.1-9.1 |
| man-db | 2.7.6.1-2 |
| manpages | 4.10-2 |
| manpages-dev | 4.10-2 |
| manpages-posix | 2013a-2 |
| manpages-posix-dev | 2013a-2 |
| moby-cli (Docker CLI) | 20.10.6+azure-1 |
| nano | 2.7.4-1 |
| ncdu | 1.12-1+b1 |
| net-tools | 1.60+git20161116.90da8a0-1 |
| openjdk-8-jdk | 8u292-b10-0+deb9u1 |
| openssh-client | 1:7.4p1-10+deb9u7 |
| openssh-server | 1:7.4p1-10+deb9u7 |
| pkg-config | 0.29-4+b1 |
| procps | 2:3.3.12-3+deb9u1 |
| psmisc | 22.21-2.1+b2 |
| python3-minimal | 3.5.3-1 |
| rsync | 3.1.2-1+deb9u2 |
| sed | 4.4-1 |
| software-properties-common | 0.96.20.2-1+deb9u1 |
| strace | 4.15-2 |
| sudo | 1.8.19p1-2.1+deb9u3 |
| tar | 1.29b-1.1 |
| unzip | 6.0-21+deb9u2 |
| valgrind | 1:3.12.0~svn20160714-1+b1 |
| vim | 2:8.0.0197-4+deb9u3 |
| vim-tiny | 2:8.0.0197-4+deb9u3 |
| wget | 1.18-5+deb9u3 |
| xtail | 2.1-5.1+b1 |
| zip | 3.0-11+b1 |
| zlib1g | 1:1.2.8.dfsg-5 |
| zsh | 5.3.1-4+deb9u4 |

