FROM python:3

ENV PYTHONUNBUFFERED 1

RUN pip install pylint

RUN mkdir /app
WORKDIR /app

ADD requirements.txt /app/
RUN pip install -r requirements.txt
ADD . /app/