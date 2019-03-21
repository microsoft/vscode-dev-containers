FROM python:2.7-slim

RUN pip install pylint

# Install git
RUN apt-get update && apt-get -y install git \
  && rm -rf /var/lib/apt/lists/*
