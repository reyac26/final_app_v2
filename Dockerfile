FROM python:3.13.13-slim-trixie@sha256:aa938a849bcb82dce8f49480f056ab82bf5c1c3ebc294f0430f37b6820e7f286

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV DJANGO_SECRET_KEY="build-time-placeholder-key-string"

ENV python manage.py collectstatic --noinput 
run python manage.py migrate --noinput
RUN chmod 666 db.sqlite3 && chmod 777 .

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
