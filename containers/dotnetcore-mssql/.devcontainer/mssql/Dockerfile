FROM mcr.microsoft.com/mssql/server:2019-latest

USER root

COPY setup.sql *.dacpac ./
COPY setup-db.sh setup-db.sh
COPY entrypoint.sh entrypoint.sh

RUN apt-get update && chmod +x entrypoint.sh && chmod +x setup-db.sh

CMD /bin/bash ./entrypoint.sh