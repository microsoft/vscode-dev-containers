# Development Container Common Script

Installs git and a set of common utilities, adds a default locale, creates a non-root user with sudo access, and optionally upgrades packages, and installs zsh and Oh My Zsh!

Script files:

- Debian/Ubuntu: `common-debian.sh`
- Alpine: `common-alpine.sh`
- RedHat: `common-redhat.sh`

## Arguments

```text
./common-debian.sh [ZSH flag] [Username] [User UID] [User GID] [Upgrade packages flag]
```

| Argument | Default | Description|
|----------|---------|------------|
| ZSH flag | `true` | Indicates whether `zsh` and [Oh My Zsh!](https://ohmyz.sh/) should be installed. |
| Username | `vscode` | Name of new user to create and provide sudo access. Set to `none` to skip. |
| User UID | `1000` | The expected [UID](https://en.wikipedia.org/wiki/User_identifier) for the user. If the user already exists and has a different UID, it will be modified to this value. Ignored if Username is set to `root` or `none`. |
| User GID | `1000` | The expected [GID](https://en.wikipedia.org/wiki/Group_identifier) for the user. If the user already exists and has a different GID, it will be modified to this value. Ignored if Username is set to `root` or `none`. |
| Upgrade packages flag | `true` | Runs `apt-get upgrade` to update all OS packages on the system to the most up to date version for current distro version. For example, update to the latest version of `curl` for Ubuntu 18.04. It will not perform a "distro upgrade" (e.g. move from Ubuntu 18.04 to 20.04). Useful to avoid security issues.

## Usage

When added to a `library-scripts` folder next to your Dockerfile, add it to the file as follows:

```Dockerfile
COPY library-scripts/common-debian.sh /tmp/library-scripts/
RUN bash /tmp/library-scripts/common-debian.sh true 1000 1000 vscode true
```

Or if `curl` is already installed, you can use a version directly from the repository:

```Dockerfile
ARG RELEASE_NUMBER=0.134.0
RUN curl -sSL -o- "hhttps://raw.githubusercontent.com/microsoft/vscode-dev-containers/v${RELEASE_NUMBER}/script-library/common-debian.sh" | bash -s -- true 1000 1000 vscode true
```
