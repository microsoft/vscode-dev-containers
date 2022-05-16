# [Choice] PHP version (use -bullseye variants on local arm64/Apple Silicon): 8, 8.1, 8.0, 7, 7.4, 7.3, 8-bullseye, 8.1-bullseye, 8.0-bullseye, 7-bullseye, 7.4-bullseye, 7.3-bullseye, 8-buster, 8.1-buster, 8.0-buster, 7-buster, 7.4-buster
ARG VARIANT=8-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/php:${VARIANT}

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# Install MS SQL ODBC
# Ref: https://docs.microsoft.com/en-us/sql/connect/php/installation-tutorial-linux-mac?view=sql-server-ver15#installing-on-debian
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN rel=$(lsb_release -r -s) && curl https://packages.microsoft.com/config/debian/$rel/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && ACCEPT_EULA=Y apt-get -y install --no-install-recommends msodbcsql18 mssql-tools18 unixodbc-dev libgssapi-krb5-2

# Instal PHP MS SQL Drivers
# Ref: https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15#debian18
RUN pecl install sqlsrv && pecl install pdo_sqlsrv
RUN printf "; priority=20\nextension=sqlsrv.so\n" > /usr/local/etc/php/conf.d/020-sqlsrv.ini \
     && printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /usr/local/etc/php/conf.d/030-pdo_sqlsrv.ini 

ENV PATH="$PATH:/opt/mssql-tools18/bin"

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1

