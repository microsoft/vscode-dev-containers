#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

FROM ubuntu:bionic

# Install git, process tools
RUN apt-get update && apt-get -y install git procps


# Install Docker CE CLI. If you choose a Debian based image, update https://download.docker.com/linux/ubuntu
# to https://download.docker.com/linux/debian on the third line below.
RUN apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli

# Install kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubectl

# Install Helm
RUN curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash -

# Copy localhost's ~/.kube/config file into the container and swap out localhost
# for host.docker.internal whenever a new shell starts to keep them in sync.
RUN echo 'if [ "$SYNC_LOCALHOST_KUBECONFIG" == "true" ]; then \
        mkdir -p $HOME/.kube \
        && cp -r $HOME/.kube-localhost/* $HOME/.kube \
        && sed -i -e "s/localhost/host.docker.internal/g" $HOME/.kube/config; \
        fi' >> $HOME/.bashrc

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
