FROM python:3

# install git iproute2
RUN apt-get update && apt-get -y install git iproute2

# Install dev tools
RUN pip install pylint

# Install tensorflow
RUN pip install tensorflow

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
