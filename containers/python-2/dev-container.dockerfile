FROM python:2-slim

RUN pip install pylint

# Install git
RUN apt-get update && apt-get -y install git

# Install any missing dependencies for enhanced language service
RUN apt-get install -y libicu57

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
