FROM java:latest

# Install required tools
RUN apt-get update \
	&& apt-get install -y git

# Install GraphViz
RUN apt-get install -y graphviz

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

