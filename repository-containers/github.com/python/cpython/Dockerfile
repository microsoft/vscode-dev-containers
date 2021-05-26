FROM ubuntu:latest

RUN apt-get -y update && sh .github/workflows/posix-deps-apt.sh \
     && apt-get clean -y && rm -rf /var/lib/apt/lists/*
RUN ./configure --with-pydebug --enable-shared && \
    make -j4 regen-all && \
    make -j4 -s
