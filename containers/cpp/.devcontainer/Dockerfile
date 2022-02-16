# [Choice] Debian / Ubuntu version (use Debian 11, Ubuntu 18.04/21.04 on local arm64/Apple Silicon): debian-11, debian-10, ubuntu-21.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT=debian-11
FROM mcr.microsoft.com/vscode/devcontainers/cpp:0-${VARIANT}

# [Optional] Install CMake version different from base image.
# [Choice] CMake Version: none, 3.21.5, 3.22.2, or versions from https://cmake.org/download/
ARG REINSTALL_CMAKE_FROM_SOURCE="false"
ARG CMAKE_VERSION="none"

# Optionally install the cmake for vcpkg
COPY library-scripts/*.sh /tmp/library-scripts/
RUN if [ "${REINSTALL_CMAKE_FROM_SOURCE}" = "true" ]; then \
        /tmp/library-scripts/reinstall-cmake.sh ${CMAKE_VERSION}; \
    fi
RUN rm -rf /tmp/library-scripts

# [Optional] Uncomment this section to install additional vcpkg ports.
# RUN su vscode -c "${VCPKG_ROOT}/vcpkg install <your-port-name-here>"

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
