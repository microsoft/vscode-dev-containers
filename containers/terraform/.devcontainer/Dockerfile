ARG TF_VERSION

FROM hashicorp/terraform:${TF_VERSION}

LABEL maintainer="Shashindran Vijayan"

WORKDIR /usr/src/app

RUN apk update

COPY . .

ENTRYPOINT ["tail", "-f", "/dev/null"]