FROM postgres:17.2-bookworm

# Set a few metadata (labels)
LABEL org.opencontainers.image.authors="Remy Chaput" \
      org.opencontainers.image.url="https://github.com/rchaput/postgres-pgadmin-docker" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.name="Postgres pgAdmin4" \
      org.opencontainers.image.description="A Docker image that contains both PostgreSQL (a database management system) and pgAdmin4 (a Web UI for Postgres), for teaching purposes."


# Set some environment variables to configure the Postgres docker image (database initialization)
ENV POSTGRES_USER='postgres'
ENV POSTGRES_PASSWORD='postgres'
ENV POSTGRES_DB='postgres'
# Warning: with method `trust`, all connections from the same container are accepted! This is not safe for production, only for teaching...
ENV POSTGRES_HOST_AUTH_METHOD='trust'


# Install pgAdmin4
# See https://www.pgadmin.org/download/pgadmin-4-apt/
# And https://hub.docker.com/r/dcagatay/pwless-pgadmin4 for passwordless
# Because pgAdmin4 only supports the amd64 architecture, we must tell dpkg
# to use this architecture, even if the current architecture is arm64.
RUN set -ex; \
    dpkg --add-architecture amd64; \
    apt-get update -y && apt-get install -y curl lsb-release; \
    curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg arch=amd64,all] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt-get update; \
    apt-get install -y pgadmin4-server uwsgi uwsgi-plugin-python3; \
    rm -rf /var/lib/apt/lists/*


# Configure pgAdmin4 and create a dedicated user (note: the dedicated user is not really used as of now)
# TODO: create dynamically the pgadmin_servers.json to use the env variables instead of hardcoding them
COPY pgadmin_servers.json /usr/pgadmin4/
COPY pgadmin_config.py /usr/pgadmin4/web/config_local.py
COPY --chmod=755 run_pgadmin.sh /usr/pgadmin4/run_pgadmin.sh
RUN \
    /usr/pgadmin4/venv/bin/python3 /usr/pgadmin4/web/setup.py setup-db; \
    /usr/pgadmin4/venv/bin/python3 /usr/pgadmin4/web/setup.py load-servers /usr/pgadmin4/pgadmin_servers.json; \
    mkdir -p /var/log/pgadmin4 /var/lib/pgadmin4; \
    echo "localhost:${POSTGRES_USER}:5432:${POSTGRES_DB}:${POSTGRES_USER}:${POSTGRES_PASSWORD}" >> /var/lib/pgadmin4/pgpass; \
    useradd --create-home --home-dir /home/pgadmin --user-group --shell /bin/false pgadmin; \
    chown -R pgadmin:pgadmin /var/lib/pgadmin4 /var/log/pgadmin4
# RUN chown -R pgadmin:pgadmin /usr/pgadmin4


# Give students the sample database
# TODO: create a pgadmin4 with home directory and put the tar there
COPY --chown=pgadmin:pgadmin --chmod=664 dvdrental.tar /root/


# Install supervisord to make both services (Postgres and pgAdmin4) run at the same time
RUN \
    apt-get update; \
    apt-get install -y supervisor; \
    mkdir -p /var/log/supervisor; \
    rm -rf /var/lib/apt/lists/*
COPY supervisord.conf /etc/supervisord.conf


# pgAdmin4 uses port 5050; Postgres already exposes 5432 in the parent image
EXPOSE 5050

# By default, start supervisord; the configuration file will launch both Postgres and pgAdmin4
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
