# [Choice] Debian / Ubuntu version (use Debian 11/9, Ubuntu 18.04/21.04 on local arm64/Apple Silicon): debian-11, debian-10, debian-9, ubuntu-21.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT=debian-11
FROM mcr.microsoft.com/vscode/devcontainers/cpp:0-${VARIANT}

# Everything Below this is needed for installing MariaDB
# Instructions are copied and modified from: https://mariadb.com/docs/clients/mariadb-connectors/connector-cpp/install/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install wget

RUN wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup \
    && chmod +x mariadb_repo_setup \
    && ./mariadb_repo_setup --mariadb-server-version="mariadb-10.6" \
    && apt install -y libmariadb3 libmariadb-dev \
    && wget https://dlm.mariadb.com/1683461/connectors/cpp/connector-cpp-1.0.1/mariadb-connector-cpp-1.0.1-debian-buster-amd64.tar.gz \
    && tar -xvzf mariadb-connector-cpp-*.tar.gz \
    && cd mariadb-connector-cpp-*/ \
    && install -d /usr/include/mariadb/conncpp \
    && install -d /usr/include/mariadb/conncpp/compat \
    && cp -R ./include/mariadb/* /usr/include/mariadb/ \
    && cp -R ./include/mariadb/conncpp/* /usr/include/mariadb/conncpp \
    && cp -R include/mariadb/conncpp/compat/* /usr/include/mariadb/conncpp/compat \
    && install -d /usr/lib/mariadb \
    && install -d /usr/lib/mariadb/plugin \
    && cp lib/mariadb/libmariadbcpp.so /usr/lib \
    && cp -R lib/mariadb/plugin/* /usr/lib/mariadb/plugin