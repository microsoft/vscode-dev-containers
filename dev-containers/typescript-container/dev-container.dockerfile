FROM node:8

# Install git
RUN apt-get update && apt-get -y install git \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g tslint typescript
