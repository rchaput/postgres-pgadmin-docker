#!/bin/sh

uwsgi \
    --http-socket 0.0.0.0:5050 \
    --processes 1 \
    --threads 25 \
    --chdir /usr/pgadmin4/web/ \
    --mount /=pgAdmin4:app \
    --plugin python3 \
    -H /usr/pgadmin4/venv/ \
    --wsgi-file /usr/pgadmin4/web/pgAdmin4.wsgi \
    --manage-script-name \
    --py-sys-executable /usr/pgadmin4/venv/bin/python
    # --uid pgadmin \
    # --gid pgadmin
