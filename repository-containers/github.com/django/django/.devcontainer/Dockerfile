FROM python:3

# install git iproute2
RUN apt-get update && apt-get -y install git iproute2

# Install node
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y nodejs

# Install dev tools
RUN pip install closure
RUN npm install -g jshint

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*