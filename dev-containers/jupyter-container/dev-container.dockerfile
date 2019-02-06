FROM jupyter/scipy-notebook:83ed2c63671f

# USER root

# RUN pip install pylint

# Install git
# RUN apt-get update && apt-get -y install git \
#   && apt-get -y install vim \
#   && apt-get install -y python-subprocess32 \
#   && apt-get install -y python-dev \
#   && rm -rf /var/lib/apt/lists/*

# RUN pip install jupyter

# USER jovyan