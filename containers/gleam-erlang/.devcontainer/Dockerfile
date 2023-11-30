FROM mcr.microsoft.com/vscode/devcontainers/base:debian

ARG GLEAM_VERSION="v0.18.2"

RUN apt-get update \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends erlang 2>&1 \
  && curl -sSL https://github.com/gleam-lang/gleam/releases/download/${GLEAM_VERSION}/gleam-${GLEAM_VERSION}-linux-amd64.tar.gz -o /tmp/gleam.tar.az \
  && tar -xzvf /tmp/gleam.tar.az -C /usr/local/bin \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* /tmp/gleam.tar.az

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install additional package.
# RUN  gleam add ...