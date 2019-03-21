FROM jupyter/scipy-notebook:83ed2c63671f

RUN apt-get update && apt-get -y install git 
   && rm -rf /var/lib/apt/lists/*
