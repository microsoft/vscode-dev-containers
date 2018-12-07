FROM node:8

RUN npm install -g eslint

# Install git
RUN apt-get update && apt-get -y install git \
  && rm -rf /var/lib/apt/lists/*