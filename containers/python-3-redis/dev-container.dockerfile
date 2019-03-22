FROM python:3
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
RUN pip install pylint
CMD ["python", "app.py"]

# Install git
RUN apt-get update && apt-get -y install git

# Install any missing dependencies for enhanced language service
RUN apt-get install libicu

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*
