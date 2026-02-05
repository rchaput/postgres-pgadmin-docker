FROM postgres:18.1-alpine

# Set a few metadata (labels)
LABEL org.opencontainers.image.authors="Remy Chaput" \
      org.opencontainers.image.url="https://github.com/rchaput/postgres-pgadmin-docker" \
      org.opencontainers.image.version="3.2" \
      org.opencontainers.image.name="Postgres pgAdmin4" \
      org.opencontainers.image.description="A Docker image that contains both PostgreSQL (a database management system) and pgAdmin4 (a Web UI for Postgres), for teaching purposes."


# Set some environment variables to configure the Postgres docker image (database initialization)
ENV POSTGRES_USER='postgres'
ENV POSTGRES_PASSWORD='postgres'
ENV POSTGRES_DB='postgres'
# Warning: with method `trust`, all connections from the same container are accepted! This is not safe for production, only for teaching...
ENV POSTGRES_HOST_AUTH_METHOD='trust'


# Install pgAdmin4.
# See https://www.pgadmin.org/download/pgadmin-4-apt/
#   and https://hub.docker.com/r/dcagatay/pwless-pgadmin4 for passwordless.
# Installing through pip (rather than apt) is easier for multi-platform...
# We also need a few dependencies to build some Python packages; we use
#   Alpine's virtual deps system to remove them easily.
# We get the path to the pgadmin4 package automatically; it should yield
#   something like `/usr/lib/python3.12/site-packages/pgadmin4`.
RUN \
    apk add --no-cache python3 py3-pip ;\
    apk add --no-cache --virtual .build-deps gcc python3-dev musl-dev linux-headers ;\
    /usr/bin/pip install --break-system-packages --no-cache-dir pgadmin4 ;\
    apk del .build-deps ;\
    rm -rf /var/cache/ ;\
    mkdir /usr/pgadmin4 && ln -s $(/usr/bin/python3 -c 'import pgadmin4; print(pgadmin4.__path__[0]);') /usr/pgadmin4/web


# Configure pgAdmin4 and create a dedicated user (note: the dedicated user is not really used as of now)
# TODO: create dynamically the pgadmin_servers.json to use the env variables instead of hardcoding them
COPY pgadmin_servers.json /usr/pgadmin4/
COPY pgadmin_config.py /usr/pgadmin4/web/config_local.py
COPY --chmod=755 run_pgadmin.sh /usr/pgadmin4/run_pgadmin.sh
RUN \
    /usr/bin/python3 /usr/pgadmin4/web/setup.py setup-db ;\
    /usr/bin/python3 /usr/pgadmin4/web/setup.py load-servers /usr/pgadmin4/pgadmin_servers.json ;\
    mkdir -p /var/log/pgadmin4 /var/lib/pgadmin4 ;\
    echo "localhost:${POSTGRES_USER}:5432:${POSTGRES_DB}:${POSTGRES_USER}:${POSTGRES_PASSWORD}" >> /var/lib/pgadmin4/pgpass ;\
    adduser -h /home/pgadmin -s /bin/false -D pgadmin ;\
    chown -R pgadmin:pgadmin /var/lib/pgadmin4 /var/log/pgadmin4
# RUN chown -R pgadmin:pgadmin /usr/pgadmin4


# Give students the sample database
# TODO: create a pgadmin4 with home directory and put the tar there
COPY --chown=pgadmin:pgadmin --chmod=664 dvdrental.tar /root/


# Install supervisord to make both services (Postgres and pgAdmin4) run at the same time
RUN apk add --no-cache supervisor ;\
    mkdir -p /var/log/supervisor ;\
    rm -rf /var/cache/
COPY supervisord.conf /etc/supervisord.conf


# pgAdmin4 uses port 5050; Postgres already exposes 5432 in the parent image
EXPOSE 5050

# By default, start supervisord; the configuration file will launch both Postgres and pgAdmin4
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
