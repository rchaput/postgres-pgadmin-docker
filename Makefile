IMAGE_NAME = postgres_pgadmin4
DOCKER_SRC = Dockerfile dvdrental.tar pgadmin_config.py pgadmin_servers.json run_pgadmin.sh supervisord.conf
CONTAINER_NAME = db
BRANCH_NAME = $(shell git branch --show-current)

build-docker: $(DOCKER_SRC)
	docker build --platform linux/amd64 --tag $(IMAGE_NAME):$(BRANCH_NAME) .

run-docker:
	docker run --platform linux/amd64 --name $(CONTAINER_NAME) -p 127.0.0.1:5432:5432 -p 127.0.0.1:5050:5050 -d $(IMAGE_NAME):$(BRANCH_NAME)

populate-docker:
	docker exec -it $(CONTAINER_NAME) /usr/bin/pg_restore -d dvdrental --create --username=postgres /root/dvdrental.tar

.PHONY: run-docker populate-docker
