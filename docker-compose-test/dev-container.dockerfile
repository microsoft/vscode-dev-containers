FROM python:3
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
RUN pip install pylint
CMD ["python", "app.py"]

