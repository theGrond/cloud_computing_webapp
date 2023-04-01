FROM python:3.9-slim-buster
WORKDIR /app
# ENV FLASK_APP=app.py
# ENV FLASK_RUN_HOST=0.0.0.0
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
# EXPOSE 8000
COPY . .
CMD ["gunicorn", "-k", "gevent", "-b", "0.0.0.0:8000", "wsgi:app"]
