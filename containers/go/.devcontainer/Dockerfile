FROM golang:1

# This Dockerfile adds a non-root user with sudo access. Update the “remoteUser” property in
# devcontainer.json to use it. More info: https://aka.ms/vscode-remote/containers/non-root-user.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    && apt-get -y install git openssh-client less iproute2 procps lsb-release \
    #
    # Build Go tools w/module support
    && mkdir -p /tmp/gotools \
    && cd /tmp/gotools \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x golang.org/x/tools/gopls 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x honnef.co/go/tools/... 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x golang.org/x/tools/cmd/gorename 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x golang.org/x/tools/cmd/goimports 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x golang.org/x/tools/cmd/guru 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x golang.org/x/lint/golint 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/mdempsky/gocode 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/cweill/gotests/... 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/haya14busa/goplay/cmd/goplay 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/sqs/goreturns 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/josharian/impl 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/davidrjenni/reftools/cmd/fillstruct 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/uudashr/gopkgs/v2/cmd/gopkgs 2>&1  \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/ramya-rao-a/go-outline 2>&1  \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/acroca/go-symbols 2>&1  \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/godoctor/godoctor 2>&1  \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/rogpeppe/godef 2>&1  \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/zmb3/gogetdoc 2>&1 \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/fatih/gomodifytags 2>&1  \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/mgechev/revive 2>&1  \
    && GOPATH=/tmp/gotools GO111MODULE=on go get -x github.com/go-delve/delve/cmd/dlv 2>&1 \
    #
    # Build gocode-gomod
    && GOPATH=/tmp/gotools go get -x -d github.com/stamblerre/gocode 2>&1 \
    && GOPATH=/tmp/gotools go build -o gocode-gomod github.com/stamblerre/gocode \
    #
    # Install Go tools
    && mv /tmp/gotools/bin/* /usr/local/bin/ \
    && mv gocode-gomod /usr/local/bin/ \
    #
    # Install golangci-lint
    && curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin 2>&1 \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/gotools

ENV GO111MODULE=auto
