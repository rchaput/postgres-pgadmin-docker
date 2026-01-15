# PostgreSQL + pgAdmin4 Docker

> Author: Remy Chaput

This Docker image contains both [PostgreSQL](https://www.postgresql.org) (a Relational Database Management System) and [pgAdmin4](https://www.pgadmin.org/) (a Web UI for Postgres), for teaching purposes.

The image is already pre-configured so that students can directly access postgres, create and query databases without having to configure neither Postgres, pgAdmin4, nor the the connection between pgAdmin4 and Postgres.

It also includes a sample database backup that can be easily and quickly restored for immediate hands-on: the [DVD Rental Database](https://github.com/gordonkwokkwok/DVD-Rental-PostgreSQL-Project), made available by Gordon Kwok. The backup file can be found at `/root/dvdrental.tar` and can be restored both from the pgAdmin4 Web UI (see [their documentation](https://www.pgadmin.org/docs/pgadmin4/latest/restore_dialog.html)) or from the command-line interface, by using the `pg_restore` tool.


## :warning: This image is unsecure :fire:

All passwords have been disabled for ease-of-use: because pgAdmin4 can access the PSQL tool (and because PSQL in turns allows to execute some system commands), any attacker with access to the pgAdmin4 Web UI has effectively **root access to the container**. Because of Docker's containerization principle, this should not allow access to the host, but escalation flaws may exist.

It is therefore **strongly recommended**:

- to **never, ever, ever use this container in production**;

- to **bind ports only to localhost** (so as to avoid attackers on the same network gaining access to your pgAdmin4 UI).

This image was made for *teaching purposes* and is not appropriate for any other use-case. You should directly use [Postgres' docker image](https://hub.docker.com/_/postgres/) and [pgAdmin4's docker image](https://hub.docker.com/r/dpage/pgadmin4) for deployments that require security. The maintainer can not be held responsible for any damage on your system.


## How to use

Pull the latest version of this image with:

```shell
docker pull rchaput/postgres_pgadmin4:latest
```

Then instantiate a new container with:

```shell
docker run --name YOUR_CONTAINER_NAME -p 127.0.0.1:5050:5050 -d rchaput/postgres_pgadmin4:latest
```

You may now access the pgAdmin4 UI at [http://localhost:5050/](http://localhost:5050/)


> [!CAUTION]
> Specifying `127.0.0.1` when binding the port ensures that only the local interface can be used to access pgAdmin4. 
> Using the (concise) `5050:5050` notation binds to *all* interfaces and is therefore **unsafe**.


## Exchanging files with pgAdmin within the container

Although pgAdmin uses a Web interface, it actually uses the container's local storage when using files, especially for backup and restore.
You may place database backups (e.g., `.tar` files) in the container's `/root` folder to be able to restore them from pgAdmin.
Conversely, when backing up a database in pgAdmin, the file is saved in the `/root` folder.

You can access this folder by either:

- using a bind mount when creating the container:

```shell
docker run --name YOUR_CONTAINER_NAME -p 127.0.0.1:5050:5050 -v YOUR_LOCAL_FOLDER:/root/data -d rchaput/postgres_pgadmin4:latest
```

where `YOUR_LOCAL_FOLDER` is the path to a desired folder (dedicated to this), for example, `/home/me/MyPgsqlData`.

- copying files to and from the container:

```shell
# To "download" (from container to host)
docker cp YOUR_CONTAINER_NAME:/root/mybackup.tar YOUR_LOCAL_FOLDER/

# To "upload" (from host to container)
docker cp YOUR_LOCAL_FOLDER/mybackup.tar YOUR_CONTAINER_NAME:/root
```

where `YOUR_CONTAINER_NAME` and `YOUR_LOCAL_FOLDER` are as previously.


## Other technical details

This image is based on the Alpine version of Postgres. For most aspects it should be quite similar to the Debian version.

Versions are:

- Alpine 3.23.0
- Postgres 18
- pgAdmin4 v9.11

You may access a shell (Bash) if necessary by using:

```shell
docker exec -it YOUR_CONTAINER_NAME bash
```

(with `YOUR_CONTAINER_NAME` the name of a running container).

---

Postgres files are located at: `/var/lib/postgresql/data`

pgAdmin4 binaries and configuration files are located at: `/usr/pgadmin4`; data files at: `/var/lib/pgadmin4`

---

You may also restore a database from backup files directly from the command line, rather than using the pgAdmin4 UI, by using the following command in a container shell:

```shell
/usr/bin/pg_restore -d YOUR_DATABASE_NAME --create --username=postgres /root/YOUR_BACKUP.tar
```

Assuming that `/root/YOUR_BACKUP.tar` points to a backup already existing or that you have placed here (see Exchanging files).

---

The base Postgres image also exposes the `5432` port for direct access to Postgres. This should not be necessary, as you can access Postgres through pgAdmin4, but you may also bind this port when instantiating the container, by using several `-p` arguments: `docker run --name YOUR_CONTAINER_NAME -p 127.0.0.1:5432:5432 -p 127.0.0.1:5050:5050 -d rchaput/postgres_pgadmin4:latest`

Of course, the host ports can be changed if 5432 or 5050 are already in use.


## Contributing

You are very welcome to fork and modify this image to suit your needs.

Pull Requests can be sent, although I'd rather avoid adding too many features; security and bugfixes patches are always welcome.

This image was made for a database/SQL course given at [CPE Lyon](https://www.cpe.fr/en/); I will not have time to work on feature requests.
